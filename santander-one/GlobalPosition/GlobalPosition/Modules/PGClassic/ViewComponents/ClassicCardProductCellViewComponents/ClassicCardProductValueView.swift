import UI
import CoreFoundationLib

final class ClassicCardProductValueView: DesignableView {
    @IBOutlet private weak var cardValueDesc: UILabel!
    @IBOutlet private weak var cardValue: UILabel!
    
    private var discreteMode: Bool = false

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.discreteMode {
            guard !(cardValue.text?.isEmpty ?? true)
            else {
                cardValue.removeBlur()
                return
            }
            cardValue.blur(5.0)
        }
    }
    
    override func commonInit() {
        super.commonInit()
        setupView()
    }
    
    func configView(info: PGCardCellViewModel, discreteMode: Bool) {
        self.discreteMode = discreteMode
        setCardValueDescLabel(info)
        setCardValueLabel(info)
        hiddesCardValuesIfNeeded(info)
    }
}

private extension ClassicCardProductValueView {
    func setupView() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityIds()
        setAccessibilityIdentifiers()
    }
    
    func setCardValueDescLabel(_ info: PGCardCellViewModel) {
        let labelConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .regular, size: 14),
            alignment: .right,
            lineBreakMode: .none
        )
        cardValueDesc.configureText(
            withKey: info.balanceTitle ?? "",
            andConfiguration: labelConfig
        )
        cardValueDesc.textColor = .lisboaGray
        cardValueDesc.numberOfLines = 1
    }
    
    func setCardValueLabel(_ info: PGCardCellViewModel) {
        cardValue.font = .santander(family: .text, type: .regular, size: 22)
        cardValue.textAlignment = .right
        cardValue.textColor = .lisboaGray
        cardValue.attributedText = info.ammount
        cardValue.numberOfLines = 1
    }
    
    func setAccessibilityIds() {
        let cardValueDesc = self.discreteMode
            ? ""
            : self.cardValueDesc.text ?? ""
        let cardValue = self.discreteMode
            ? ""
            : self.cardValue.text ?? ""
        self.accessibilityValue = "\(cardValueDesc) \n \(cardValue)"
    }
    
    func setAccessibilityIdentifiers() {
        cardValue.accessibilityIdentifier = AccessibilityGlobalPosition.pgClassicCardValue
        cardValueDesc.accessibilityIdentifier = AccessibilityGlobalPosition.pgClassicCardValueDesc
    }
    
    func hiddesCardValuesIfNeeded(_ info: PGCardCellViewModel) {
        if !info.toActivate {
            cardValueDesc.isHidden = (info.ammount?.length ?? 0) == 0
            cardValue.isHidden = (info.ammount?.length ?? 0) == 0
        }
    }
}
