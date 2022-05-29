import UIKit

class AccountHeaderViewModel: HeaderViewModel<AccountOperativeHeaderView> {
    
    // MARK: - Private attributes
    
    private let accountAlias: String
    private let accountIBAN: String
    private let accountAmount: String
    
    // MARK: - Public methods
    
    init(accountAlias: String, accountIBAN: String, accountAmount: String) {
        self.accountAlias = accountAlias
        self.accountIBAN = accountIBAN
        self.accountAmount = accountAmount
    }
    
    override func configureView(_ view: AccountOperativeHeaderView) {
        view.configure(alias: "\(accountAlias) ", iban: accountIBAN, amount: accountAmount)
    }
}
