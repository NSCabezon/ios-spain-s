import UIKit

protocol FormatedTextFieldTableViewCellDelegate: class {
}

class FormatedTextFieldTableViewCell: BaseViewCell {
    
    var textFormatMode: FormattedTextField.FormatMode! {
        didSet {
            textField.textFormatMode = textFormatMode
            textField.delegate = textField.parser
        }
    }
    
    var styledPlaceholder: LocalizedStylableText? {
        didSet {
            textField.setOnPlaceholder(localizedStylableText: styledPlaceholder ?? .empty)
        }
    }
    
    var newTextFieldValue: ((_ value: String?) -> Void)?
    
    @IBOutlet weak var textField: FormattedTextField! {
        didSet {
            textField.keyboardType = .decimalPad
            textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingDidEnd)
            (textField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 16.0), textAlignment: .left))
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    @objc
    func textFieldChanged(_ textField: UITextField) {
        newTextFieldValue?(textField.text)
    }
}
