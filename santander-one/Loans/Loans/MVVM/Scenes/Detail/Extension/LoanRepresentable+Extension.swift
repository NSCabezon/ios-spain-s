
import CoreDomain
import CoreFoundationLib

extension LoanRepresentable {
    var availableBigAmountAttributedString: NSAttributedString? {
        guard let availableAmount: AmountEntity = self.currentBalanceAmount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32)
        let amount = MoneyDecorator(availableAmount, font: font, decimalFontSize: 18)
        return amount.getFormatedCurrency()
    }
    
    public var currentBalanceAmount: AmountEntity? {
        return currentBalanceAmountRepresentable.map(AmountEntity.init)
    }
}
