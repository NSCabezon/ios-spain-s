import CoreFoundationLib

protocol LoadAccountTransactionProtocol {
    var referenceId: Int { get }
}

class LoadAccountTransactionsOperation: UseCaseOperationWeakFatherImpl<WidgetAccountsTransactionsSuperUseCase, WidgetAccountTransactionsUseCaseInput, WidgetAccountTransactionsUseCaseOkOutput, StringErrorOutput>, LoadAccountTransactionProtocol {
    let referenceId: Int
    
    init(_ parent: WidgetAccountsTransactionsSuperUseCase, useCase: UseCase<WidgetAccountTransactionsUseCaseInput, WidgetAccountTransactionsUseCaseOkOutput, StringErrorOutput>, referenceId: Int) {
        self.referenceId = referenceId
        super.init(parent, useCase: useCase)
        errorHandler = LoadAccountTransactionsOperationErrorHandler(parent: self)
        finishQueue = .noChange
    }
    
    func exceptionError() {
        parent?.errorTransactions(operation: self)
    }
    
    override func onSuccess(result: WidgetAccountTransactionsUseCaseOkOutput) {
        super.onSuccess(result: result)
        parent?.reciveTransactions(operation: self, response: result)
    }
    
    override func onError(err: StringErrorOutput) {
        super.onError(err: err)
        parent?.errorTransactions(operation: self)
    }
}

class LoadAccountTransactionsOperationErrorHandler: UseCaseErrorHandler {
    weak var parent: LoadAccountTransactionsOperation?
    
    init(parent: LoadAccountTransactionsOperation) {
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
