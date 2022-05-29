import CoreFoundationLib

struct WithholdingViewModel {
    let entity: WithholdingEntity
    let currency: String
    let fixedLabel: String
    
    var entryDate: String {
        return dateToString(date: entity.entryDate, outputFormat: .dd_MMM_yyyy)?.uppercased() ?? ""
    }
    
    var leavingDate: String {
        return dateToString(date: entity.leavingDate, outputFormat: .dd_MMM_yyyy)?.uppercased() ?? ""
    }
    var concept: String {
        return entity.concept
    }
    
    func getAmountFormatted(font: UIFont) -> NSAttributedString? {
        let amount = AmountEntity(value: entity.amount)
        var amountDecorator = MoneyDecorator(amount, font: font)
        if amount.value?.isSignMinus == true {
            amountDecorator =  MoneyDecorator(amount.changedSign, font: font)
        }
        return amountDecorator.getCurrencyWithoutFormat()
    }
}
