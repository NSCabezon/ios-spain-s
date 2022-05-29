import Foundation
import CoreFoundationLib

protocol LoadStockSuperUseCaseDelegate: class {
    func updateStockAccount (position: Int)
}

typealias LoadStockFinishClousure = (_ stocks: [StockAccount: [Stock]], _ ibexSan: IbexSanQuotes?) -> Void

enum StockResult {
    case success(stockAccount: StockAccount, stocks: [Stock])
    case error(GetStocksUseCaseErrorOutput)
    case loading
}

typealias OperationStockInfo = (operation: LoadStockOperation, account: StockAccount)
typealias IbexSanQuotes = (ibex: StockQuote?, san: StockQuote?)

class LoadStockSuperUseCase {
    
    private let useCaseProvider: UseCaseProvider
    private let useCaseHandler: UseCaseHandler
    private var operations: [Int: Foundation.Operation & LoadStockOperationProtocol]
    private var results: [Int: StockResult]
    private var totalRequests: Int = 0
    private var ibexSan: IbexSanQuotes?
    weak var delegate: LoadStockSuperUseCaseDelegate?
    var isFinish: Bool {
        return totalRequests == 0
    }
    var clousureFinish: LoadStockFinishClousure? {
        didSet {
            checkIsFinish()
        }
    }

    init(useCaseProvider: UseCaseProvider, useCaseHandler: UseCaseHandler) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
        self.operations = [:]
        self.results = [:]
    }
    
    // MARK: - Class methods
    
    func getStocks(stockAccounts: [StockAccount], first: Int) {
        cancelAll()
        results.removeAll()
        totalRequests = stockAccounts.count + 1
        if stockAccounts.count > first {
            let stockAccount = stockAccounts[first]
            executeStockAccount(stockAccount: stockAccount, index: first)
        }
        executeIbexSan(index: stockAccounts.count)
        var index: Int = 0
        for stockAccount in stockAccounts {
            if index != first {
                executeStockAccount(stockAccount: stockAccount, index: index)
            }
            index += 1
        }
    }
    
    func getStock(position: Int) -> StockResult? {
        return results[position]
    }
    
    func errorStockAccount(referenceId: Int, error: GetStocksUseCaseErrorOutput) {
        results[referenceId] = StockResult.error(error)
        self.delegate?.updateStockAccount(position: referenceId)
        operations[referenceId] = nil
        reduceAndCheckFinish()
    }
    
    func successStockAccount(operation: LoadStockOperation, response: GetStocksUseCaseOkOutput) {
        results[operation.referenceId] = StockResult.success(stockAccount: operation.stockAccount, stocks: response.stocks)
        self.delegate?.updateStockAccount(position: operation.referenceId)
        operations[operation.referenceId] = nil
        reduceAndCheckFinish()
    }
    
    func cancelAll () {
        for operation in operations.values {
            operation.cancel()
        }
        operations.removeAll()
        totalRequests = 0
    }
    
    func errorStockIbexSan(referenceId: Int, error: StringErrorOutput) {
        operations[referenceId] = nil
        reduceAndCheckFinish()
    }
    
    func successStockIbexSan(referenceId: Int, response: GetStockIbexSanUseCaseOkOutput) {
        self.delegate?.updateStockAccount(position: referenceId)
        ibexSan = IbexSanQuotes(ibex: response.stockIbex, san: response.stockSan)
        operations[referenceId] = nil
        reduceAndCheckFinish()
    }
    
    // MARK: - Private Methods
    
    private func executeStockAccount(stockAccount: StockAccount, index: Int) {
        let input = GetStocksUseCaseInput(account: stockAccount)
        let usecase = useCaseProvider.getStocksUseCase(input: input)
        let operation = LoadStockOperation(self, useCase: usecase, referenceId: index, stockAccount: stockAccount)
        operation.queuePriority = Operation.QueuePriority.veryHigh
        results[index] = .loading
        operations[index] = operation
        useCaseHandler.execute(operation)
    }

    private func executeIbexSan (index: Int) {
        let usecase = useCaseProvider.getStockIbexSanUseCase()
        let operation = LoadStockIbexSanOperation(self, useCase: usecase, referenceId: index)
        operation.queuePriority = Operation.QueuePriority.high
        operations[index] = operation
        useCaseHandler.execute(operation)
    }
    
    private func checkIsFinish () {
        if isFinish, let clousureFinish = clousureFinish {
            let ibexSanQuote = ibexSan
            let resultsList = results
            DispatchQueue.global(qos: .background).async {
                var stocksByAccount: [StockAccount: [Stock]] = [:]
                for case let .success(account, stocks) in resultsList.values {
                    stocksByAccount[account] = stocks
                }
                DispatchQueue.main.async {
                    clousureFinish(stocksByAccount, ibexSanQuote)
                }
            }
        }
    }
    
    private func reduceAndCheckFinish () {
        totalRequests -= 1
        checkIsFinish()
    }
}

// MARK: Use case operations

protocol LoadStockOperationProtocol {
    var referenceId: Int { get }
}

class LoadStockOperation: UseCaseOperationImpl<LoadStockSuperUseCase, GetStocksUseCaseInput, GetStocksUseCaseOkOutput, GetStocksUseCaseErrorOutput>, LoadStockOperationProtocol {
    
    let referenceId: Int
    let stockAccount: StockAccount
    private weak var usecase: Cancelable?
    
    init(_ parent: LoadStockSuperUseCase, useCase: UseCase<GetStocksUseCaseInput, GetStocksUseCaseOkOutput, GetStocksUseCaseErrorOutput> & Cancelable, referenceId: Int, stockAccount: StockAccount) {
        self.referenceId = referenceId
        self.usecase = useCase
        self.stockAccount = stockAccount
        super.init(parent, useCase: useCase)
        errorHandler = LoadStockOperationErrorHandler(parent: parent, referenceId: referenceId)
    }
    
    override func onSuccess(result: GetStocksUseCaseOkOutput) {
        super.onSuccess(result: result)
        parent.successStockAccount(operation: self, response: result)
    }
    
    override func onError(err: GetStocksUseCaseErrorOutput) {
        super.onError(err: err)
        parent.errorStockAccount(referenceId: referenceId, error: err)
    }
    
    override open func cancel() {
        super.cancel()
        usecase?.cancel()
    }
}

class LoadStockIbexSanOperation: UseCaseOperationImpl<LoadStockSuperUseCase, Void, GetStockIbexSanUseCaseOkOutput, StringErrorOutput>, LoadStockOperationProtocol {
    
    let referenceId: Int
    
    init(_ parent: LoadStockSuperUseCase, useCase: UseCase<Void, GetStockIbexSanUseCaseOkOutput, StringErrorOutput>, referenceId: Int) {
        self.referenceId = referenceId
        super.init(parent, useCase: useCase)
        errorHandler = LoadStockOperationErrorHandler(parent: parent, referenceId: referenceId)
    }
    
    override func onSuccess(result: GetStockIbexSanUseCaseOkOutput) {
        super.onSuccess(result: result)
        parent.successStockIbexSan(referenceId: referenceId, response: result)
    }
    
    override func onError(err: StringErrorOutput) {
        super.onError(err: err)
        parent.errorStockIbexSan(referenceId: referenceId, error: err)
    }
    
    private func exceptionError () {
        let error = StringErrorOutput(nil)
        parent.errorStockIbexSan(referenceId: referenceId, error: error)
    }
}

// MARK: - UseCaseErrorHandler

class LoadStockOperationErrorHandler: UseCaseErrorHandler {
    
    let referenceId: Int
    weak var parent: LoadStockSuperUseCase?
    
    init(parent: LoadStockSuperUseCase, referenceId: Int) {
        self.parent = parent
        self.referenceId = referenceId
    }
    
    private func exceptionError () {
        let error = GetStocksUseCaseErrorOutput(nil)
        parent?.errorStockAccount(referenceId: referenceId, error: error)
    }
    
    func unauthorized() {
        exceptionError()
    }
    
    func showNetworkUnavailable() {
        exceptionError()
    }
    
    func showGenericError() {
        exceptionError()
    }
}
