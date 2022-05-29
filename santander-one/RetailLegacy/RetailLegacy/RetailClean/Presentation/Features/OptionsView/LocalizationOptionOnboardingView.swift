import UIKit
import UI
import CoreFoundationLib

class LocalizationOptionOnboardingView: StackItemView {
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
        set {
            self.switchButton.isOn = newValue
        }
        get {
            return self.switchButton.isOn
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        self.separatorView.backgroundColor = .mediumSky
        self.titleLabel.applyStyle(LabelStylist(textColor: .uiBlack, font: .santanderTextBold(size: 20), textAlignment: .left))
        self.descriptionLabel.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: .santanderTextLight(size: 16), textAlignment: .left))
        self.switchLabel.applyStyle(LabelStylist(textColor: .uiBlack, font: .santanderTextRegular(size: 17), textAlignment: .left))
        self.mapImage.image = Assets.image(named: "imgMapOnboarding")
        self.loadingView.setSecondaryLoader(scale: 2.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shadowContentView.drawShadow(offset: CGSize(width: 0.0, height: 2.0), opaticity: 0.7, color: UIColor.lightSanGray, radius: 3.0)
        self.shadowContentView.layer.masksToBounds = false
        self.contentView.drawBorder(cornerRadius: 6.0, color: UIColor.mediumSky)
        self.contentView.layer.masksToBounds = true
    }
    
    func setTitleText(_ text: LocalizedStylableText) {
        self.titleLabel.set(localizedStylableText: text)
    }
    
    func setDescriptionText(_ text: LocalizedStylableText) {
        self.descriptionLabel.set(localizedStylableText: text)
        self.descriptionLabel.set(lineHeightMultiple: 0.85)
    }
    
    func setSwitchText(_ text: LocalizedStylableText) {
        self.switchLabel.set(localizedStylableText: text)
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
        guard let accessibilityIdentifier = accessibilityIdentifier else { return }
        self.switchLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingSwitchLabelGeolocation
        self.switchButton.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingSwitchGeolocation
        self.mapImage.accessibilityIdentifier = AccessibilityOnboardingOptions.mapImage
        self.titleLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingLabelGeolocation
        self.descriptionLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingTextGeolocation
    }
}
