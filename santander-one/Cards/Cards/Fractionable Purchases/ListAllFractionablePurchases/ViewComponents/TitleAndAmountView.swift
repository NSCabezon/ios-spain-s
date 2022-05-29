import UI
import CoreFoundationLib

final class TitleAndAmountView: XibView {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ model: FractionablePurchaseViewModel) {
        setTitleLabel(model)
        let attributedText = createAttributedStringForAmount(model.amount)
        self.amountLabel.attributedText = attributedText
    }
}

private extension TitleAndAmountView {
    func setupView() {
        setAccesibilityIdentifier()
    }
    
    func setAccesibilityIdentifier() {
        self.accessibilityIdentifier = AccessibilityListAllFractionablePurchases.titleAndAmountView
        self.titleLabel.accessibilityIdentifier = AccessibilityListAllFractionablePurchases.titleAndAmountViewTitleLabel
        self.amountLabel.accessibilityIdentifier = AccessibilityListAllFractionablePurchases.titleAndAmountViewAmountLabel
    }
    
    func setTitleLabel(_ model: FractionablePurchaseViewModel) {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .regular, size: 16),
            alignment: .left
        )
        self.titleLabel.configureText(
            withKey: model.movementTitle ?? "",
            andConfiguration: localizedConfig
        )
    }
    
    func createAttributedStringForAmount(_ amount: AmountEntity?) -> NSAttributedString {
        guard let amount = amount else { return NSAttributedString() }
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 20), decimalFontSize: 16)
        return moneyDecorator.getFormatedCurrency() ?? NSAttributedString()
        return NSAttributedString()
    }
}
