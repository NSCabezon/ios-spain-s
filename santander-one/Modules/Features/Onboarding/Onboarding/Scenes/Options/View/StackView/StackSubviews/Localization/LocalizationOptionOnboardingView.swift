import UIKit
import UI
import CoreFoundationLib

class LocalizationOptionOnboardingView: OnboardingStackViewBase {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            self.descriptionLabel.numberOfLines = 0
        }
    }
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet private weak var switchLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet private weak var shadowContentView: UIView!
    @IBOutlet private weak var mapImage: UIImageView!
    
    var switchValueDidChange: ((Bool) -> Void)?
    
    var isSwitchOn: Bool {
        get {
            return self.switchButton.isOn
        }
        set {
            self.switchButton.isOn = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        self.separatorView.backgroundColor = .mediumSky
        self.titleLabel.applyStyle(LabelStylist(textColor: .black,
                                                font: .santander(family: .text, type: .bold, size: 20),
                                                textAlignment: .left))
        self.descriptionLabel.applyStyle(LabelStylist(textColor: .lisboaGray,
                                                      font: .santander(family: .text, type: .light, size: 16),
                                                      textAlignment: .left))
        self.switchLabel.applyStyle(LabelStylist(textColor: .black,
                                                 font: .santander(family: .text, type: .regular, size: 17),
                                                 textAlignment: .left))
        self.mapImage.image = Assets.image(named: "imgMapOnboarding")
        self.loadingView.setPointsLoader()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shadowContentView.drawShadow(offset: (x: 0, y: 2), opacity: 0.5, color: .lightSanGray, radius: 4.0)
        self.shadowContentView.layer.masksToBounds = false
        self.contentView.drawBorder(cornerRadius: 6.0, color: UIColor.mediumSky)
        self.contentView.layer.masksToBounds = true
    }
    
    func setTitleText(_ text: LocalizedStylableText) {
        self.titleLabel.configureText(withLocalizedString: text)
    }
    
    func setDescriptionText(_ text: LocalizedStylableText) {
        self.descriptionLabel.configureText(withLocalizedString: text,
                                            andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
    }
    
    func setSwitchText(_ text: LocalizedStylableText) {
        self.switchLabel.configureText(withLocalizedString: text)
    }
    
    func updateSwitchValue() {
        self.switchButton.setOn(!switchButton.isOn, animated: true)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        DispatchQueue.main.async {
            sender.setOn(!sender.isOn, animated: false)
        }
        self.switchValueDidChange?(sender.isOn)
    }
    
    func setAccesibilityIdentifers(_ accessibilityIdentifier: String?) {
        guard accessibilityIdentifier != nil else { return }
        self.switchLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingSwitchLabelGeolocation
        self.switchButton.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingSwitchGeolocation
        self.mapImage.accessibilityIdentifier = AccessibilityOnboardingOptions.mapImage
        self.titleLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingLabelGeolocation
        self.descriptionLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingTextGeolocation
    }
}
