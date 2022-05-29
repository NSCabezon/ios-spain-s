import CoreFoundationLib

struct ReceivedTransferDetailAmountViewModel {
    private let amount: AmountEntity
    let concept: String?
    
    init(amount: AmountEntity, concept: String?) {
        self.amount = amount
        self.concept = concept
    }
    
    var transferAmount: NSAttributedString? {
        let decorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32), decimalFontSize: 18)
        return decorator.formatAsMillions()
    }
}
