import UIKit
import UI
import CoreFoundationLib

class CustomOptionOnboardingView: OnboardingStackViewBase {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var iconContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var switchButton: UISwitch!
    @IBOutlet private weak var switchLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var shadowContentView: UIView!
    private var option: CustomOptionOnboarding?
    var switchValueDidChange: ((Bool) -> Void)?
    var isSwitchOn: Bool {
        get {
            return switchButton.isOn
        }
        set {
            switchButton.isOn = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.separatorView.backgroundColor = .mediumSky
        self.iconContentView.clipsToBounds = true
        self.iconContentView.backgroundColor = .paleSanGray
        self.titleLabel.applyStyle(LabelStylist(textColor: .black,
                                                font: .santander(family: .text, type: .bold, size: 20),
                                                textAlignment: .left))
        self.descriptionLabel.applyStyle(LabelStylist(textColor: .lisboaGray,
                                                      font: .santander(family: .text, type: .light, size: 16),
                                                      textAlignment: .left))
        self.switchLabel.applyStyle(LabelStylist(textColor: .black,
                                                 font: .santander(family: .text, type: .regular, size: 17),
                                                 textAlignment: .left))
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.sizeToFit()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shadowContentView.drawShadow(offset: (x: 0, y: 2), opacity: 0.5, color: .lightSanGray, radius: 4.0)
        self.shadowContentView.layer.masksToBounds = false
        self.contentView.drawBorder(cornerRadius: 6.0, color: UIColor.mediumSky)
        self.contentView.layer.masksToBounds = true
    }
    
    func set(title: LocalizedStylableText, description: LocalizedStylableText, image: String) {
        self.titleLabel.configureText(withLocalizedString: title)
        self.descriptionLabel.configureText(withLocalizedString: description,
                                      andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        self.iconImageView.image = Assets.image(named: image)
    }
    
    func setSwitchText(_ text: LocalizedStylableText) {
        switchLabel.configureText(withLocalizedString: text)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switchValueDidChange?(sender.isOn)
    }
}
