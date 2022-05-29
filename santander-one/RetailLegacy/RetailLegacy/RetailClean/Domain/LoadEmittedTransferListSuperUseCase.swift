import Foundation
import CoreFoundationLib
import SANLegacyLibrary

protocol LoadEmittedTransferListDelegate: class {
    func didReceiveEmittedTransfers(_ transfers: [(data: TransferEmitted, account: Account)])
}

class LoadEmittedTransferListSuperUseCase {
    
    typealias ListRequest = (operation: Foundation.Operation, pageNumber: Int)
    
    private let useCaseProvider: UseCaseProvider
    private let useCaseHandler: UseCaseHandler
    private var operations: [Account: ListRequest] {
        didSet {
            if isFinish {
                sortResults(completion: { [weak self] in
                    DispatchQueue.main.async {
                        guard let strongSelf = self else { return }
                        strongSelf.delegate?.didReceiveEmittedTransfers(strongSelf.result)
                    }
                })
            }
        }
    }
    private var result: [(data: TransferEmitted, account: Account)]
    private let maxRequestingPages: Int
    private let searchMonths: Int
    private var threadsRequired = -1
    private let lockCommonProperties = DispatchSemaphore(value: 1)
    var isFinish = false
    weak var delegate: LoadEmittedTransferListDelegate?
    
    init(useCaseProvider: UseCaseProvider, useCaseHandler: UseCaseHandler, appConfigRepository: AppConfigRepository) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
        self.operations = [:]
        self.result = []
        if let stringMaxPages: String = appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigEmittedTransfersMaxPagination), let maxPages = Int(stringMaxPages) {
            self.maxRequestingPages = maxPages
        } else {
            self.maxRequestingPages = 1
        }
        if let stringMonths: String = appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigEmittedTransfersSearchMonths), let months = Int(stringMonths) {
            self.searchMonths = months
        } else {
            self.searchMonths = 1
        }
    }
    
    func execute() {
        UseCaseWrapper(with: useCaseProvider.getLoadGlobalPositionV2UseCase(), useCaseHandler: useCaseHandler, errorHandler: nil, onSuccess: { [weak self] _ in
            self?.requestGlobalPosition()
        }, onGenericErrorType: { [weak self] _ in
            self?.requestGlobalPosition()
        })
    }
    
    private func requestGlobalPosition() {
        loadGlobalPosition()
            .execute(on: useCaseProvider.dependenciesResolver.resolve())
            .onSuccess(didLoadGlobalPosition)
            .onError { [weak self] _ in
                self?.delegate?.didReceiveEmittedTransfers([])
            }
    }
    
    private func getEmittedTransfersFor(account: Account, page: PaginationDO?) {
        let date = DateFilterDO.createSubtractingMonths(months: searchMonths)
        let input = GetEmittedTransfersUseCaseInput(account: account, pagination: page, amountFrom: nil, amountTo: nil, dateFilter: date)
        let usecase = useCaseProvider.getEmittedTransfersUseCase(input: input)
        let operation = LoadEmittedTransfersOperation(self, useCase: usecase, account: account)
        operation.qualityOfService = QualityOfService.userInitiated
        lockCommonProperties.wait()
        let pageRequest = operations[account]?.pageNumber ?? 0
        operations[account] = (operation, pageRequest + 1)
        lockCommonProperties.signal()
        useCaseHandler.execute(operation)
    }
    
    func successPage(forAccount account: Account, response: GetEmittedTransfersUseCaseOkOutput) {
        lockCommonProperties.wait()
        let pageRequested = operations[account]?.pageNumber ?? 0
        let isNotEndList = response.nextPage?.endList == false
        lockCommonProperties.signal()
        if isNotEndList, pageRequested <= maxRequestingPages {
            getEmittedTransfersFor(account: account, page: response.nextPage)
        } else {
            let r = response.transferList.map {($0, account)}
            lockCommonProperties.wait()
            result.append(contentsOf: r)
            threadsRequired -= 1
            isFinish = threadsRequired == 0
            operations[account] = nil
            lockCommonProperties.signal()
        }
    }
    
    func errorPage(forAccount account: Account, error: GetEmittedTransfersUseCaseErrorOutput) {
        lockCommonProperties.wait()
        threadsRequired -= 1
        isFinish = threadsRequired == 0
        operations[account] = nil
        lockCommonProperties.signal()
    }
    
    private func sortResults(completion: @escaping () -> Void) {
        result = result.sorted {
            if $0.data.executedDate != $1.data.executedDate {
                return $0.data.executedDate ?? Date() > $1.data.executedDate ?? Date()
            } else if $0.data.amount?.amountDTO.value != $1.data.amount?.amountDTO.value {
                return $0.data.amount?.amountDTO.value ?? 0 > $1.data.amount?.amountDTO.value ?? 0
            } else {
                return $0.data.beneficiary?.camelCasedString ?? "" < $1.data.beneficiary?.camelCasedString ?? ""
            }
        }
        completion()
    }
    
    func cancel() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.lockCommonProperties.wait()
            for request in strongSelf.operations.values {
                request.operation.cancel()
            }
            strongSelf.lockCommonProperties.signal()
        }
    }
    
    private func loadGlobalPosition() -> Scenario<Void, LoadGlobalPositionUseCaseOKOutput, StringErrorOutput> {
        return Scenario(useCase: useCaseProvider.dependenciesResolver.resolve(firstTypeOf: LoadGlobalPositionUseCase.self))
    }
    
    private func didLoadGlobalPosition(_ result: LoadGlobalPositionUseCaseOKOutput) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else {
                self?.delegate?.didReceiveEmittedTransfers([])
                return
            }
            let accounts = result.globalPosition.accounts
            strongSelf.result = []
            strongSelf.lockCommonProperties.wait()
            strongSelf.threadsRequired = accounts.count
            strongSelf.isFinish = strongSelf.threadsRequired == 0
            strongSelf.lockCommonProperties.signal()
            for account in accounts {
                strongSelf.getEmittedTransfersFor(account: Account(account), page: nil)
            }
        }
    }
}

class LoadEmittedTransfersOperation: UseCaseOperationImpl<LoadEmittedTransferListSuperUseCase, GetEmittedTransfersUseCaseInput, GetEmittedTransfersUseCaseOkOutput, GetEmittedTransfersUseCaseErrorOutput> {
    typealias UseCaseLoadEmittedType = UseCase<GetEmittedTransfersUseCaseInput, GetEmittedTransfersUseCaseOkOutput, GetEmittedTransfersUseCaseErrorOutput> & Cancelable
    weak var usecase: UseCaseLoadEmittedType?
    let account: Account
    
    init(_ parent: LoadEmittedTransferListSuperUseCase, useCase: UseCaseLoadEmittedType, account: Account) {
        self.usecase = useCase
        self.account = account
        super.init(parent, useCase: useCase)
        errorHandler = LoadEmittedTransfersOperationErrorHandler(parent: parent, account: account)
        finishQueue = .noChange
    }
        
    override func onSuccess(result: GetEmittedTransfersUseCaseOkOutput) {
        //super.onSuccess(result: result)
        parent.successPage(forAccount: account, response: result)
    }
    
    override func onError(err: GetEmittedTransfersUseCaseErrorOutput) {
        super.onError(err: err)
        parent.errorPage(forAccount: account, error: err)
    }
    
    override open func cancel() {
        super.cancel()
        usecase?.cancel()
    }
}

class LoadEmittedTransfersOperationErrorHandler: UseCaseErrorHandler {
    
    let account: Account
    weak var parent: LoadEmittedTransferListSuperUseCase?
    
    init(parent: LoadEmittedTransferListSuperUseCase, account: Account) {
        self.parent = parent
        self.account = account
    }
    
    private func exceptionError() {
        let error = GetEmittedTransfersUseCaseErrorOutput(nil)
        parent?.errorPage(forAccount: account, error: error)
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
