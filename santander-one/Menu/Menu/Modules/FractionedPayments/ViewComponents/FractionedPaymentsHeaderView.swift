import UI
import CoreFoundationLib

final class FractionedPaymentsHeaderView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bottomSeparatorView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension FractionedPaymentsHeaderView {
    func setupView() {
        backgroundColor = .clear
        bottomSeparatorView.backgroundColor = .mediumSkyGray
        setTitleLabel()
        setAccessibilityIds()
    }
    
    func setTitleLabel() {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .bold, size: 14),
            alignment: .left,
            lineHeightMultiple: 0.80,
            lineBreakMode: .none
        )
        titleLabel.configureText(
            withKey: "financing_label_movements",
            andConfiguration: localizedConfig
        )
        titleLabel.textColor = .lisboaGray
        titleLabel.numberOfLines = 1
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionedPaymentsView.headerBaseView
        titleLabel.accessibilityIdentifier = AccessibilityFractionedPaymentsView.headerTitleLabel
    }
}
