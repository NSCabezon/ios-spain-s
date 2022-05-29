import CoreFoundationLib

struct WithholdingAmountViewModel {
    let amount: AmountEntity
    
    func getAmountFormatted(font: UIFont) -> NSAttributedString? {
        let amountDecorator = MoneyDecorator(amount, font: font, decimalFontSize: 14.0)
        return amountDecorator.getFormatedCurrency()
    }
}
