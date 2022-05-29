import Foundation
import CoreFoundationLib

protocol LoadStockQuotesSuperUseCaseDelegate: class {
    func updateIndex (index: Int)
}

class LoadStockQuotesSuperUseCase {
    
    private let useCaseProvider: UseCaseProvider
    private let useCaseHandler: UseCaseHandler
    private weak var delegate: LoadStockQuotesSuperUseCaseDelegate?
    private var operations: [Int: LoadStockQuotesOperation]
    private var errorHandler: GenericPresenterErrorHandler

    init(useCaseProvider: UseCaseProvider, useCaseHandler: UseCaseHandler, delegate: LoadStockQuotesSuperUseCaseDelegate, errorHandler: GenericPresenterErrorHandler) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
        self.operations = [:]
        self.delegate = delegate
        self.errorHandler = errorHandler
    }
    
    func getDetailQuote(stock: StockBase, index: Int) {
        let input = GetStockQuoteDetailUseCaseInput(stock: stock)
        let usecase = useCaseProvider.getStockQuoteDetailUseCase(input: input)
        let operation = LoadStockQuotesOperation(self, useCase: usecase)
        operation.queuePriority = Operation.QueuePriority.normal
        operations[index] = operation
        useCaseHandler.execute(operation)
    }
    
    func updateOperation(operation: LoadStockQuotesOperation) {
        if let tupple = operations.first(where: { (_, value) -> Bool in
            return value == operation
        }) {
            self.delegate?.updateIndex(index: tupple.key)
        }
    }
    
    func cancelOperation(operation: LoadStockQuotesOperation) {
        if let tupple = operations.first(where: { (_, value) -> Bool in
            return operation == value
        }) {
            operations[tupple.key] = nil
        }
    }
    
    func cancelIndex(index: Int) {
        if let operation = operations[index] {
            operation.cancel()
            operations[index] = nil
        }
    }
    
    func cancelAll () {
        for operation in operations.values {
            operation.cancel()
        }
    }
}

// MARK: Use case operations

class LoadStockQuotesOperation: UseCaseOperationImpl<LoadStockQuotesSuperUseCase, GetStockQuoteDetailUseCaseInput, GetStockQuoteDetailUseCaseOkOutput, GetStockQuoteDetailUseCaseErrorOutput> {
    
    override func onSuccess(result: GetStockQuoteDetailUseCaseOkOutput) {
        super.onSuccess(result: result)
        parent.updateOperation(operation: self)
        parent.cancelOperation(operation: self)
    }
    
    override func onError(err: GetStockQuoteDetailUseCaseErrorOutput) {
        super.onError(err: err)
        parent.updateOperation(operation: self)
        parent.cancelOperation(operation: self)
    }
    
    override func genericError() {
        super.genericError()
        parent.cancelOperation(operation: self)
    }
    
    override func inernalError() {
        super.inernalError()
        parent.cancelOperation(operation: self)
    }
}
