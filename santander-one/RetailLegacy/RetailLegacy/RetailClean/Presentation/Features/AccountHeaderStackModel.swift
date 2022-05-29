import Foundation

class AccountHeaderStackModel: StackItem<AccountHeaderStackView> {
    // MARK: - Private attributes
    
    private let accountAlias: String
    private let accountIBAN: String
    private let accountAmount: String
    
    // MARK: - Public methods
    
    init(accountAlias: String, accountIBAN: String, accountAmount: String, insets: Insets = Insets(left: 14, right: 20, top: 20, bottom: 0)) {
        self.accountAlias = accountAlias
        self.accountIBAN = accountIBAN
        self.accountAmount = accountAmount
        super.init(insets: insets)
    }
    
    override func bind(view: AccountHeaderStackView) {
        view.configure(alias: "\(accountAlias) ", iban: accountIBAN, amount: accountAmount)
    }
}
