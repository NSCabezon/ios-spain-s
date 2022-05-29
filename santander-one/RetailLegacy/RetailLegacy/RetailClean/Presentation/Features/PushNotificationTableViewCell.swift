import UIKit
import UI

class PushNotificationTableViewCell: GroupableTableViewCell {
    @IBOutlet weak var markAsNewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkButton: CheckButton!
    @IBOutlet weak var arrowIconImage: UIImageView!
        
    var title: LocalizedStylableText? {
        didSet {
            if let text = title {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var message: LocalizedStylableText? {
        didSet {
            if let text = message {
                messageLabel.set(localizedStylableText: text)
            } else {
                messageLabel.text = nil
            }
        }
    }
    
    var date: LocalizedStylableText? {
        didSet {
            if let text = date {
                dateLabel.set(localizedStylableText: text)
            } else {
                dateLabel.text = nil
            }
        }
    }
    
    var read: Bool? {
        didSet {
            if let markAsRead = read, markAsRead == true {
                markAsNewLabel.isHidden = true
            } else {
                markAsNewLabel.isHidden = false
            }
        }
    }
    
    var markAsNew: LocalizedStylableText? {
        didSet {
            if let text = markAsNew {
                markAsNewLabel.set(localizedStylableText: text)
            } else {
                markAsNewLabel.text = nil
            }
        }
    }
    
    var isEdition: Bool? {
        didSet {
            if let isEditionActivate = isEdition, isEditionActivate == true {
                checkButton.isHidden = false
                arrowIconImage.isHidden = true
                checkButton.isSelected = false
            } else {                
                checkButton.isHidden = true
                arrowIconImage.isHidden = false
            }
        }
    }
    
    var checkSelected: Bool? {
        didSet {
            if let isCheckSelected = checkSelected, isCheckSelected == true {
                checkButton.isSelected = true
            } else {
                checkButton.isSelected = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        markAsNewLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoBold(size: 10.0), textAlignment: .left))
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoSemibold(size: 16.0), textAlignment: .left))
        messageLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 14.0), textAlignment: .left))
        dateLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoRegular(size: 12.0), textAlignment: .right))
        setupCheckButton()
    }
    
    func setupCheckButton() {
        checkButton.onImage = Assets.image(named: "checkBoxOk")
        checkButton.offImage = Assets.image(named: "checkBoxCopy2")
    }
    
    override var roundedView: UIView {
        return containerView
    }
}
