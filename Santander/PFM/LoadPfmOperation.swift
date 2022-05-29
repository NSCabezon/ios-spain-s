import Foundation
import CoreFoundationLib
import CoreFoundationLib

protocol LoadPfmProtocol {
    var referenceId: Int { get }
}

class LoadCardsOperation: UseCaseOperationImpl<LoadPfmSuperUseCaseHelper, GetAllCardTransactionsUseCaseInput, GetAllCardTransactionsUseCaseOkOutput, GetAllCardTransactionsUseCaseErrorOutput>, LoadPfmProtocol {
    let referenceId: Int
    let page: Int
    let card: CardEntity
    weak var usecase: (UseCase<GetAllCardTransactionsUseCaseInput, GetAllCardTransactionsUseCaseOkOutput, GetAllCardTransactionsUseCaseErrorOutput> & Cancelable)?
    
    init(_ parent: LoadPfmSuperUseCaseHelper, useCase: UseCase<GetAllCardTransactionsUseCaseInput, GetAllCardTransactionsUseCaseOkOutput, GetAllCardTransactionsUseCaseErrorOutput> & Cancelable, referenceId: Int, card: CardEntity, page: Int) {
        self.referenceId = referenceId
        self.usecase = useCase
        self.card = card
        self.page = page
        super.init(parent, useCase: useCase)
        errorHandler = LoadCardsOperationErrorHandler(parent: parent, operation: self, card: card)
        finishQueue = .noChange
    }
    
    override func onSuccess(result: GetAllCardTransactionsUseCaseOkOutput) {
        super.onSuccess(result: result)
        parent.successCard(operation: self, response: result, card: card)
    }
    
    override func onError(err: GetAllCardTransactionsUseCaseErrorOutput) {
        super.onError(err: err)
        parent.errorCard(operation: self, error: err, card: card)
    }
    
    override open func cancel() {
        super.cancel()
        usecase?.cancel()
    }
}

class LoadAccountsOperation: UseCaseOperationImpl<LoadPfmSuperUseCaseHelper, GetAllAccountTransactionsUseCaseInput, GetAllAccountTransactionsUseCaseOkOutput, GetAllAccountTransactionsUseCaseErrorOutput>, LoadPfmProtocol {
    let referenceId: Int
    let page: Int
    let account: AccountEntity
    weak var usecase: (UseCase<GetAllAccountTransactionsUseCaseInput, GetAllAccountTransactionsUseCaseOkOutput, GetAllAccountTransactionsUseCaseErrorOutput> & Cancelable)?
    
    init(_ parent: LoadPfmSuperUseCaseHelper, useCase: UseCase<GetAllAccountTransactionsUseCaseInput, GetAllAccountTransactionsUseCaseOkOutput, GetAllAccountTransactionsUseCaseErrorOutput> & Cancelable, referenceId: Int, account: AccountEntity, page: Int) {
        self.referenceId = referenceId
        self.usecase = useCase
        self.account = account
        self.page = page
        super.init(parent, useCase: useCase)
        errorHandler = LoadAccountsOperationErrorHandler(parent: parent, operation: self, account: account)
        finishQueue = .noChange
    }
    
    override func onSuccess(result: GetAllAccountTransactionsUseCaseOkOutput) {
        super.onSuccess(result: result)
        parent.successAccount(operation: self, response: result, account: account)
    }
    
    override func onError(err: GetAllAccountTransactionsUseCaseErrorOutput) {
        super.onError(err: err)
        parent.errorAccount(operation: self, error: err, account: account)
    }
    
    override open func cancel() {
        super.cancel()
        usecase?.cancel()
    }
}

// MARK: - UseCaseErrorHandler

private class LoadCardsOperationErrorHandler: UseCaseErrorHandler {
    
    weak var parent: LoadPfmSuperUseCaseHelper?
    weak var operation: LoadCardsOperation?
    let card: CardEntity
    
    init(parent: LoadPfmSuperUseCaseHelper, operation: LoadCardsOperation, card: CardEntity) {
        self.parent = parent
        self.operation = operation
        self.card = card
    }
    
    private func exceptionError () {
        guard let operation = operation else { return }
        let error = GetAllCardTransactionsUseCaseErrorOutput(nil)
        parent?.errorCard(operation: operation, error: error, card: card)
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

private class LoadAccountsOperationErrorHandler: UseCaseErrorHandler {
    
    weak var parent: LoadPfmSuperUseCaseHelper?
    weak var operation: LoadAccountsOperation?
    let account: AccountEntity
    
    init(parent: LoadPfmSuperUseCaseHelper, operation: LoadAccountsOperation, account: AccountEntity) {
        self.parent = parent
        self.operation = operation
        self.account = account
    }
    
    private func exceptionError () {
        guard let operation = operation else { return }
        let error = GetAllAccountTransactionsUseCaseErrorOutput(nil)
        parent?.errorAccount(operation: operation, error: error, account: account)
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
