import UIKit
import CoreFoundationLib

class PhoneTableViewCell: GroupableTableViewCell {

    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var titleLabel: CoachmarkUILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var phone1Label: UILabel!
    @IBOutlet weak var phone2Label: UILabel!
    @IBOutlet weak var primaryPhoneView: UIView!
    @IBOutlet weak var secondaryPhoneView: UIView!
    @IBOutlet weak var containerView: UIView!
    var didSelectPhone1: (() -> Void)?
    var didSelectPhone2: (() -> Void)?
    
    override var isFirst: Bool {
        didSet {
            topSeparatorView.isHidden = isFirst
        }
    }
    
    var titleLabelCoachmarkId: CoachmarkIdentifier? {
        get {
            return self.titleLabel.coachmarkId
        } set {
            self.titleLabel.coachmarkId = newValue
        }
    }
    
    override var roundedView: UIView {
        return containerView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        (titleLabel as UILabel).applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
        phone1Label.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 28.0)))
        phone2Label.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 28.0)))
        topSeparatorView.backgroundColor = .lisboaGray
        primaryPhoneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phone1Pressed(_:))))
        secondaryPhoneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phone2Pressed(_:))))
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    func setSubtitle(_ subtitle: String?) {
        subtitleLabel.text = subtitle
    }
    
    func setPhone1(_ phone: String?) {
        phone1Label.text = phone
    }

    func setPhone2(_ phone: String?) {
        secondaryPhoneView.isHidden = phone.isNil
        phone2Label.text = phone
    }

    @IBAction func phone1Pressed(_ sender: UITapGestureRecognizer) {
        didSelectPhone1?()
    }

    @IBAction func phone2Pressed(_ sender: UITapGestureRecognizer) {
        didSelectPhone2?()
    }
    
}
