import UI
import CoreFoundationLib

final class ClassicCardProductUnreadMovementsView: DesignableView {
    @IBOutlet private weak var stackView: UIStackView!

    override func commonInit() {
        super.commonInit()
        setupView()
    }

    func configView(_ info: PGGeneralCellViewModelProtocol) {
        removeArrangedSubviewsIfNeeded()
        addNumberLabelToStack(info)
        addMovementsLabelToStack(info)
    }
}

private extension ClassicCardProductUnreadMovementsView {
    func setupView() {
        backgroundColor = .clear
    }
    
    func addNumberLabelToStack(_ info: PGGeneralCellViewModelProtocol) {
        let numberLabel = UILabel()
        numberLabel.textColor = .santanderRed
        numberLabel.numberOfLines = 1
        numberLabel.text = String(info.notification ?? 0)
        numberLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgClassicCardMovNum
        let numberLabelConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .bold, size: 14),
            alignment: .center,
            lineBreakMode: .none
        )
        if let movCount = info.notification, movCount > 0 {
            numberLabel.configureText(
                withKey: String(movCount),
                andConfiguration: numberLabelConfig
            )
        }
        let numberAccessibilityValue = numberLabel.text ?? ""
        accessibilityValue = "\(numberAccessibilityValue)"
        stackView.addArrangedSubview(numberLabel)
    }
    
    func addMovementsLabelToStack(_ info: PGGeneralCellViewModelProtocol) {
        let movementsLabel = UILabel()
        movementsLabel.textColor = .brownGray
        movementsLabel.numberOfLines = 1
        movementsLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgClassicCardMovDesc
        if let movCount = info.notification, movCount > 0 {
            let movementsLabelConfig = LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .regular, size: 14),
                alignment: .left,
                lineBreakMode: .none
            )
            let localizedText = (movCount > 1)
                ? PGCommonTexts.localizableTextForElement(.classicGeneralProductCell(.plural))
                : PGCommonTexts.localizableTextForElement(.classicGeneralProductCell(.singular))
            movementsLabel.configureText(
                withLocalizedString: localizedText,
                andConfiguration: movementsLabelConfig
            )
        }
        let movenetsAccessibilityValue = movementsLabel.text ?? ""
        accessibilityValue = "\(movenetsAccessibilityValue)"
        stackView.addArrangedSubview(movementsLabel)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        stackView.arrangedSubviews.map { $0.removeFromSuperview() }
    }
}
