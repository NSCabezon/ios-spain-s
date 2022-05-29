import CoreFoundationLib

public protocol GetAccountHomeActionUseCaseProtocol: UseCase<GetAccountHomeActionUseCaseInput, GetAccountHomeActionUseCaseOkOutput, StringErrorOutput> {}

public struct GetAccountHomeActionUseCaseInput {
    public let account: AccountEntity

    public init(account: AccountEntity) {
        self.account = account
    }
}

public struct GetAccountHomeActionUseCaseOkOutput {
    let actions: [AccountActionType]
    
    public init(actions: [AccountActionType]) {
        self.actions = actions
    }
}
