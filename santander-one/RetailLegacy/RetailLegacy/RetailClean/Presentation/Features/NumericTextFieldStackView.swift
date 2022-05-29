import UIKit

class NumericTextFieldStackView: StackItemView {
    
    @IBOutlet weak var textField: FormattedTextField! {
        didSet {
            textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            (textField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 15.0), textAlignment: .left))
        }
    }
    var styledPlaceholder: LocalizedStylableText? {
        didSet {
            let attrs = [NSAttributedString.Key.font: UIFont.latoItalic(size: 16.0), .foregroundColor: UIColor.sanGreyMedium]
            textField.setOnPlaceholder(localizedStylableText: styledPlaceholder ?? .empty, attributes: attrs)
        }
    }
    var newTextFieldValue: ((_ value: String?) -> Void)?
    lazy var setTextFieldValue: ((String?) -> Void) = { [weak self] value in
        self?.textField.text = value
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func setText(text: String?) {
        textField.text = text
    }
    
    func setNumericMode(_ mode: FormattedTextField.FormatMode) {
        textField.textFormatMode = mode
    }
    
    func setAccessibilityIdentifiers(identifier: String) {
        textField.rightImageIdentifier = "\(identifier)_textField_rightImage"
        textField.accessibilityIdentifier = "\(identifier)_textField_field"
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        newTextFieldValue?(textField.text)
    }
    
}
