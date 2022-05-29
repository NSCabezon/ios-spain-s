import Foundation
import CoreDomain
import CoreFoundationLib

extension LoanTransactionRepresentable {
    var alias: String {
        return description?.capitalized ?? ""
    }
    
    var formattedAmount: NSAttributedString? {
        guard let amount = self.amountRepresentable else { return nil }
        let font = UIFont.santander(type: .bold, size: 32)
        let moneyDecorator = AmountRepresentableDecorator(amount, font: font)
        return moneyDecorator.getFormatedCurrency()
    }
    
    var operationDate: String? {
        return dateToString(date: operationDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
    
    var annotationDate: String? {
        return dateToString(date: valueDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
}
