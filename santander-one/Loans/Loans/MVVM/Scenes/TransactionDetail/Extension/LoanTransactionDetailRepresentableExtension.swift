import Foundation
import CoreDomain
import CoreFoundationLib

extension LoanTransactionDetailRepresentable {
    var formattedCapitalAmount: String? {
        guard let amount = capitalRepresentable else { return nil }
        return AmountRepresentableDecorator(amount, font: UIFont.santander(size: 32)).getStringValue()
    }
    
    var formattedInterestAmount: String? {
        guard let amount = interestRepresentable else { return nil }
        return AmountRepresentableDecorator(amount, font: UIFont.santander(size: 32)).getStringValue()
    }
    
    func recipientAccountNumber(formatter: AccountNumberFormatterProtocol) -> String? {
        return formatter.accountNumberFormat(recipientAccountNumber)
    }
}
