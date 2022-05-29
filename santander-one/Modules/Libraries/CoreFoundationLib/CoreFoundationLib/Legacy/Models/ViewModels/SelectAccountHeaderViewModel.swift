public struct SelectAccountHeaderViewModel {
    
    private let account: AccountEntity
    public let title: String
    public let action: (() -> Void)?
    public let accessibilityIdTitle: String?
    
    public init(account: AccountEntity,
                title: String,
                accessibilityIdTitle: String?,
                action: (() -> Void)?) {
        self.account = account
        self.title = title
        self.accessibilityIdTitle = accessibilityIdTitle
        self.action = action
    }
    
    public var alias: String {
        return account.alias ?? ""
    }
    
    public var currentBalanceAmount: AmountEntity? {
        return account.currentBalanceAmount
    }
}
