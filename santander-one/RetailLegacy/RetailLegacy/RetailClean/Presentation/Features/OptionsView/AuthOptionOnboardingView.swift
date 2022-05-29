import UIKit
import UI
import CoreFoundationLib

class AuthOptionOnboardingView: StackItemView {
    @IBOutlet private weak var authIconImageView: UIImageView!
    @IBOutlet private weak var authContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet private weak var switchLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var shadowContentView: UIView!
        
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
        self.authContentView.clipsToBounds = true
        self.authContentView.backgroundColor = .paleSanGrey
        self.titleLabel.applyStyle(LabelStylist(textColor: .uiBlack, font: .santanderTextBold(size: 20), textAlignment: .left))
        self.descriptionLabel.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: .santanderTextLight(size: 16), textAlignment: .left))
        self.switchLabel.applyStyle(LabelStylist(textColor: .uiBlack, font: .santanderTextRegular(size: 17), textAlignment: .left))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shadowContentView.drawShadow(offset: CGSize(width: 0.0, height: 2.0), opaticity: 0.7, color: UIColor.lightSanGray, radius: 3.0)
        self.shadowContentView.layer.masksToBounds = false
        self.contentView.drawBorder(cornerRadius: 6.0, color: UIColor.mediumSky)
        self.contentView.layer.masksToBounds = true
    }
    
    func setType(_ type: BiometryTypeEntity, _ faceId: String, _ touchId: String, _ stringLoader: StringLoader) {
        switch type {
        case .faceId, .error(BiometryTypeEntity.faceId, _):
            self.setIconImage("icnFaceIdOnboarding")
            self.setTitle(faceId, stringLoader)
        case .touchId, .error(BiometryTypeEntity.touchId, _):
            self.setIconImage("icnTouchIdOnboarding")
            self.setTitle(touchId, stringLoader)
        case .error: break
        case .none: break
        }
    }
    
    func setDescriptionText(_ type: BiometryTypeEntity, _ faceId: String, _ touchId: String, _ stringLoader: StringLoader) {
        switch type {
        case .faceId, .error(BiometryTypeEntity.faceId, _):
            self.descriptionLabel.set(localizedStylableText: stringLoader.getString(faceId))
            //self.descriptionLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingTextFaceId
        case .touchId, .error(BiometryTypeEntity.touchId, _):
            self.descriptionLabel.set(localizedStylableText: stringLoader.getString(touchId))
            //self.descriptionLabel.accessibilityIdentifier = touchId
        case .error: break
        case .none: break
        }
        self.descriptionLabel.set(lineHeightMultiple: 0.85)
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.sizeToFit()
        setNeedsLayout()
    }
    
    func setSwitchText(_ text: String, _ stringLoader: StringLoader) {
        self.switchLabel.set(localizedStylableText: stringLoader.getString(text))
        //self.switchLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingSwitchLabelFaceId
        //self.switchButton.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingSwitchFaceId
    }
    func setAccessibilityIdentifiers(_ type: BiometryTypeEntity) {
        switch type {
        case .faceId, .error(BiometryTypeEntity.faceId, _):
            self.titleLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingLabelFaceId
            self.descriptionLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingTextFaceId
            self.authIconImageView.accessibilityIdentifier = AccessibilityOnboardingOptions.faceIdImage
            self.switchLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingSwitchLabelFaceId
            self.switchButton.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingSwitchFaceId
        case .touchId, .error(BiometryTypeEntity.touchId, _):
            self.titleLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingLabelTouchId
            self.descriptionLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingTextTouchId
            self.authIconImageView.accessibilityIdentifier = AccessibilityOnboardingOptions.touchIdImage
            self.switchLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingSwitchLabelTouchId
            self.switchButton.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingSwitchTouchId
        case .error: break
        case .none: break
        }
    }
}

private extension AuthOptionOnboardingView {
    func setIconImage(_ name: String) {
        self.authIconImageView.image = Assets.image(named: name)
        //self.authIconImageView.accessibilityIdentifier = AccessibilityOnboardingOptions.faceIdImage
    }
    
    func setTitle(_ title: String, _ stringLoader: StringLoader) {
        self.titleLabel.set(localizedStylableText: stringLoader.getString(title))
        //self.titleLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.onboardingLabelFaceId
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        self.switchValueDidChange?(sender.isOn)
    }
}
