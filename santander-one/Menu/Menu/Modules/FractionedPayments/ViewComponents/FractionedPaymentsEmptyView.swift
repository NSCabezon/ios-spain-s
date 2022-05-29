import UI
import CoreFoundationLib

final class FractionedPaymentsEmptyView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var emptyImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(titleText: LocalizedStylableText, descriptionText: String) {
        setTitleLabel(titleText)
        setDescriptionLabel(descriptionText)
    }
}

private extension FractionedPaymentsEmptyView {
    func setupView() {
        backgroundColor = .clear
        emptyImageView.setLeavesLoader()
        setAccessibilityIds()
    }
    
    func setTitleLabel(_ titleText: LocalizedStylableText) {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .headline, type: .regular, size: 18),
            alignment: .center,
            lineBreakMode: .none
        )
        titleLabel.configureText(
            withLocalizedString: titleText,
            andConfiguration: localizedConfig
        )
        titleLabel.textColor = .lisboaGray
        titleLabel.numberOfLines = 0
    }
    
    func setDescriptionLabel(_ descriptionText: String) {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .regular, size: 16),
            alignment: .center,
            lineBreakMode: .none
        )
        descriptionLabel.configureText(
            withKey: descriptionText,
            andConfiguration: localizedConfig
        )
        descriptionLabel.textColor = .lisboaGray
        descriptionLabel.numberOfLines = 0
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionedPaymentsView.emptyBaseView
        titleLabel.accessibilityIdentifier = AccessibilityFractionedPaymentsView.emptyTitleLabel
        descriptionLabel.accessibilityIdentifier = AccessibilityFractionedPaymentsView.emptyDescriptionLabel
        emptyImageView.accessibilityIdentifier = AccessibilityFractionedPaymentsView.emptyImageView
    }
}
