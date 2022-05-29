import UIKit

class PushNotificationLocationTableViewCell: BaseViewCell {
    @IBOutlet weak var emailSmsLabel: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var emailSmsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var emailSmsContainer: UIView!
    @IBOutlet weak var settingsContainer: UIView!
    
    var emailAndSmsTitle: LocalizedStylableText? {
        didSet {
            if let text = emailAndSmsTitle {
                emailSmsLabel.set(localizedStylableText: text)
            } else {
                emailSmsLabel.text = nil
            }
        }
    }

    var settingsTitle: LocalizedStylableText? {
        didSet {
            if let text = settingsTitle {
                settingsLabel.set(localizedStylableText: text)
            } else {
                settingsLabel.text = nil
            }
        }
    }
    
    var isEmailSms: Bool? {
        didSet {
            if isEmailSms == true {
                emailSmsContainer.alpha = 1
                emailSmsContainer.isUserInteractionEnabled = true
            } else {
                emailSmsContainer.alpha = 0
                emailSmsContainer.isUserInteractionEnabled = false
            }
        }
    }
    
    var isSettings: Bool? {
        didSet {
            if isSettings == true {
                settingsContainer.alpha = 1
                settingsContainer.isUserInteractionEnabled = true
            } else {
                settingsContainer.alpha = 0
                settingsContainer.isUserInteractionEnabled = false
            }
        }
    }
    
    var actionEmailSms: (() -> Void)?
    var actionSettings: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        emailSmsLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 14.0), textAlignment: .center))
        settingsLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 14.0), textAlignment: .center))
        emailSmsLabel.numberOfLines = 2
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        emailSmsContainer.drawRoundedAndShadowed()
        settingsContainer.drawRoundedAndShadowed()
    }
    
    @IBAction func touchEmailSms(_ sender: Any) {
        actionEmailSms?()
    }
    
    @IBAction func touchSettings(_ sender: Any) {
        actionSettings?()
    }    
}
