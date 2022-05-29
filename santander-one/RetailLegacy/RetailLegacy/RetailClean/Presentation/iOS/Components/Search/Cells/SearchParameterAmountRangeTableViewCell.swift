import UIKit

class SearchParameterAmountRangeTableViewCell: BaseViewCell, ChangeTextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleFromLabel: UILabel!
    @IBOutlet weak var titleToLabel: UILabel!
    @IBOutlet weak var textFieldFrom: FormattedTextField!
    @IBOutlet weak var textFieldTo: FormattedTextField!
    var didChangeTextFieldFrom: ((String?) -> Void)?
    var didChangeTextFieldTo: ((String?) -> Void)?

    func title(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func fromTitle(_ title: LocalizedStylableText) {
        titleFromLabel.set(localizedStylableText: title)
    }
    
    func toTitle(_ title: LocalizedStylableText) {
        titleToLabel.set(localizedStylableText: title)
    }
    
    var fromText: String? {
        set {
            textFieldFrom.formatWith(string: newValue)
        }
        get {
            return textFieldFrom.text
        }
    }
    
    var toText: String? {
        set {
            textFieldTo.formatWith(string: newValue)
        }
        get {
            return textFieldTo.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .darkGray, font: UIFont.latoBold(size: 14.0), textAlignment: .left))
        
        titleFromLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoBoldItalic(size: 14), textAlignment: .left))
        titleToLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoBoldItalic(size: 14), textAlignment: .left))
        
        textFieldFrom.textFormatMode = .defaultCurrency(12, 2)
        textFieldTo.textFormatMode = .defaultCurrency(12, 2)
        (textFieldFrom as UITextField).applyStyle(TextFieldStylist(textColor: UIColor.darkGray, font: UIFont.latoRegular(size: 16.0), textAlignment: .left))
        (textFieldTo as UITextField).applyStyle(TextFieldStylist(textColor: UIColor.darkGray, font: UIFont.latoRegular(size: 16.0), textAlignment: .left))
        textFieldFrom.customDelegate = self
        textFieldTo.customDelegate = self
        
        textFieldFrom.keyboardType = .decimalPad
        textFieldTo.keyboardType = .decimalPad
    }
    
    func willChangeText(textField: UITextField, text: String) {
        if textField == textFieldFrom {
            didChangeTextFieldFrom?(text)
        } else {
            didChangeTextFieldTo?(text)
        }
    }
}
