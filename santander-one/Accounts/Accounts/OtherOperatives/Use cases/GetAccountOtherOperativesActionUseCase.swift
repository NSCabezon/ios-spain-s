import CoreFoundationLib

public protocol GetAccountOtherOperativesActionUseCaseProtocol: UseCase<GetAccountOtherOperativesActionUseCaseInput, GetAccountOtherOperativesActionUseCaseOkOutput, StringErrorOutput> {}

public struct GetAccountOtherOperativesActionUseCaseInput {
    public let account: AccountEntity
    
    public init(account: AccountEntity) {
        self.account = account
    }
}

public struct GetAccountOtherOperativesActionUseCaseOkOutput {
    let everyDayOperatives: [AccountActionType]
    let otherOperativeActions: [AccountActionType]
    let adjustAccounts: [AccountActionType]
    let queriesActions: [AccountActionType]
    let contractActions: [AccountActionType]
    let officeArrangementActions: [AccountActionType]
    
    @available(*, deprecated, message: "Use the other constructor instead")
    public init(everyDayOperatives: [AccountActionType], otherOperativeActions: [AccountActionType], queriesActions: [AccountActionType], contractActions: [AccountActionType], officeArrangementActions: [AccountActionType]) {
        self.everyDayOperatives = everyDayOperatives
        self.otherOperativeActions = otherOperativeActions
        self.adjustAccounts = []
        self.queriesActions = queriesActions
        self.contractActions = contractActions
        self.officeArrangementActions = officeArrangementActions
    }
    
    public init(everyDayOperatives: [AccountActionType], otherOperativeActions: [AccountActionType], adjustAccounts: [AccountActionType], queriesActions: [AccountActionType], contractActions: [AccountActionType], officeArrangementActions: [AccountActionType]) {
        self.everyDayOperatives = everyDayOperatives
        self.otherOperativeActions = otherOperativeActions
        self.adjustAccounts = adjustAccounts
        self.queriesActions = queriesActions
        self.contractActions = contractActions
        self.officeArrangementActions = officeArrangementActions
    }
}
