import CoreFoundationLib

protocol QuickBalanceTransactionOperationProtocol {
    var referenceId: Int { get }
}

class QuickBalanceTransactionsOperation: UseCaseOperationWeakFatherImpl<QuickBalanceTransactionsSuperUseCase, QuickBalanceTransactionsUseCaseInput, QuickBalanceTransactionsUseCaseOkOutput, StringErrorOutput>, QuickBalanceTransactionOperationProtocol {
    let referenceId: Int
    
    init(_ parent: QuickBalanceTransactionsSuperUseCase, useCase: UseCase<QuickBalanceTransactionsUseCaseInput, QuickBalanceTransactionsUseCaseOkOutput, StringErrorOutput>, referenceId: Int) {
        self.referenceId = referenceId
        super.init(parent, useCase: useCase)
        errorHandler = QuickBalanceTransactionsOperationErrorHandler(parent: self)
        finishQueue = .noChange
    }
    
    func exceptionError() {
        self.parent?.errorTransactions(operation: self)
    }
    
    override func onSuccess(result: QuickBalanceTransactionsUseCaseOkOutput) {
        super.onSuccess(result: result)
        self.parent?.reciveTransactions(operation: self, response: result)
    }
    
    override func onError(err: StringErrorOutput) {
        super.onError(err: err)
        self.parent?.errorTransactions(operation: self)
    }
}

class QuickBalanceTransactionsOperationErrorHandler: UseCaseErrorHandler {
    weak var parent: QuickBalanceTransactionsOperation?
    
    init(parent: QuickBalanceTransactionsOperation) {
        self.parent = parent
    }
    
    private func exceptionError() {
        parent?.exceptionError()
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
