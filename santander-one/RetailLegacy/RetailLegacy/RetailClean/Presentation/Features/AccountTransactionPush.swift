import Foundation
import CoreFoundationLib

struct AccountTransactionPush: Codable {
    public var accountName: String
    public var ccc: String
    public var date: String?
    public var currency: String?
    public var value: String?
    
    var amount: String? {
        guard let value = value, let currency = currency else {
            return nil
        }
        return buildAmount(value: value, currency: currency)?.getFormattedAmountUI(2)
    }
    
    init(accountName: String, ccc: String, date: String?, currency: String?, value: String?) {
        self.accountName = accountName
        self.ccc = ccc
        self.date = date
        self.currency = currency
        self.value = value
    }
    
    init(accountTransactionInfo: AccountTransactionPushProtocol) {
        self.accountName = accountTransactionInfo.accountName
        self.ccc = accountTransactionInfo.ccc
        self.date = accountTransactionInfo.date
        self.currency = accountTransactionInfo.currency
        self.value = accountTransactionInfo.value
    }
    
    private func buildAmount(value: String, currency: String) -> Amount? {
        guard let decimal = Decimal(string: value) else {
            return nil
        }
        let amount = Amount.create(value: decimal, currency: Currency.create(withName: currency))
        return amount
    }
}
