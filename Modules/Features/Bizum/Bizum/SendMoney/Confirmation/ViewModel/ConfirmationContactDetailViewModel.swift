import CoreFoundationLib

struct ConfirmationContactDetailViewModel {
    let identifier: String?
    let name: String?
    let alias: String?
    let initials: String?
    let phone: String
    let amount: AmountEntity?
    let validateSendAction: String?
    let colorModel: ColorsByNameViewModel
    public var thumbnailData: Data?

    var amountAttributeString: NSAttributedString? {
        guard let amount = amount else { return nil }
        let font: UIFont = UIFont.santander(family: .text, type: .regular, size: 20)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 16.0)
        return decorator.getFormatedCurrency()
    }
}
