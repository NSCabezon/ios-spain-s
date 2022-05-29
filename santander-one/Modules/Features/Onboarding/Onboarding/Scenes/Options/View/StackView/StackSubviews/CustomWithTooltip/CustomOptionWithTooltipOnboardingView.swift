import UIKit
import UI
import CoreFoundationLib

final class CustomOptionWithTooltipOnboardingView: OnboardingStackViewBase {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var iconContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var shadowContentView: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.separatorView.backgroundColor = .mediumSky
        self.iconContentView.clipsToBounds = true
        self.iconContentView.backgroundColor = .paleSanGray
        self.titleLabel.applyStyle(LabelStylist(textColor: .black,
                                                font: .santander(family: .text, type: .bold, size: 20),
                                                textAlignment: .left))
        self.titleLabel.numberOfLines = 0
        self.descriptionLabel.applyStyle(LabelStylist(textColor: .lisboaGray,
                                                      font: .santander(family: .text, type: .light, size: 16),
                                                      textAlignment: .left))
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.sizeToFit()
        self.setAccesibilityIdentifers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shadowContentView.drawShadow(offset: (x: 0, y: 2), opacity: 0.5, color: .lightSanGray, radius: 4.0)
        self.shadowContentView.layer.masksToBounds = false
        self.contentView.drawBorder(cornerRadius: 6.0, color: UIColor.mediumSky)
        self.contentView.layer.masksToBounds = true
    }
    
    func set(title: LocalizedStylableText,
             description: LocalizedStylableText,
             image: String) {
        self.titleLabel.configureText(withLocalizedString: title,
                                      andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.8))
        self.descriptionLabel.configureText(withLocalizedString: description,
                                            andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        self.iconImageView.image = Assets.image(named: image)
    }
}

private extension CustomOptionWithTooltipOnboardingView {
    func setAccesibilityIdentifers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.titleCard
        self.descriptionLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.descriptionCard
    }
}
