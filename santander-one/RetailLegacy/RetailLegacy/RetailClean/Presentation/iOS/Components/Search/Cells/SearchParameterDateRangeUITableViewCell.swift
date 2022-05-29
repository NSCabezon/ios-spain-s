import UIKit
import UI

class SearchParameterDateRangeUITableViewCell: BaseViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    var textFieldFromTapped: (() -> Void)?
    var textFieldToTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoBold(size: 16), textAlignment: .left))
        subtitleLabel.applyStyle(LabelStylist(textColor: .darkGray, font: UIFont.latoBold(size: 14), textAlignment: .left))
        fromLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoBoldItalic(size: 14), textAlignment: .left))
        toLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoBoldItalic(size: 14), textAlignment: .left))
        fromTextField.applyStyle(TextFieldStylist(textColor: UIColor.darkGray, font: UIFont.latoRegular(size: UIScreen.main.isIphone4or5 ? 14 : 16), textAlignment: .left))
        toTextField.applyStyle(TextFieldStylist(textColor: UIColor.darkGray, font: UIFont.latoRegular(size: UIScreen.main.isIphone4or5 ? 14 : 16), textAlignment: .left))
        
        let fromImage = UIImageView(image: Assets.image(named: "icnCalendarRetail"))
        fromImage.contentMode = .scaleAspectFit
        fromImage.frame = CGRect(x: 0.0, y: 0.0, width: fromImage.bounds.size.width + 20, height: fromImage.bounds.size.height)
        
        fromTextField.rightViewMode = .always
        fromTextField.rightView = fromImage
        
        let toImage = UIImageView(image: Assets.image(named: "icnCalendarRetail"))
        toImage.contentMode = .scaleAspectFit
        toImage.frame = CGRect(x: 0.0, y: 0.0, width: toImage.bounds.size.width + 20, height: toImage.bounds.size.height)
        
        toTextField.rightViewMode = .always
        toTextField.rightView = toImage
        backgroundColor = UIColor.clear
        toTextField.delegate = self
        fromTextField.delegate = self
        
        separator.backgroundColor = .lisboaGray
    }
    
    func title(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func subtitle(_ subTitle: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: subTitle)
    }
    
    func fromTitle(_ title: LocalizedStylableText) {
        fromLabel.set(localizedStylableText: title)
    }
    
    func toTitle(_ title: LocalizedStylableText) {
        toLabel.set(localizedStylableText: title)
    }
    
    var fromText: String? {
        set {
            fromTextField.text = newValue
        }
        get {
            return fromTextField.text
        }
    }
    
    var toText: String? {
        set {
            toTextField.text = newValue
        }
        get {
            return toTextField.text
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == fromTextField {
            textFieldFromTapped?()
        } else {
            textFieldToTapped?()
        }
        return false
    }
    
    var bottomSpace: Double = 16 {
        didSet {
            bottomSpaceConstraint.constant = CGFloat(bottomSpace)
        }
    }
}
