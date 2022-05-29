import UIKit

class TextFieldStackView: StackItemView {
    var styledPlaceholder: LocalizedStylableText? {
        didSet {
            let attrs = [NSAttributedString.Key.font: UIFont.latoItalic(size: 16.0), .foregroundColor: UIColor.sanGreyMedium]
            textField.setOnPlaceholder(localizedStylableText: styledPlaceholder ?? .empty, attributes: attrs)
        }
    }
    var newTextFieldValue: ((_ value: String?) -> Void)?
    @IBOutlet weak var textField: CustomTextField! {
        didSet {
            textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingDidEnd)
            (textField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 15.0), textAlignment: .left))
        }
    }
    lazy var setTextFieldValue: ((String?) -> Void) = { [weak self] value in
        self?.textField.text = value
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    func setText(text: String?) {
        textField.text = text
        textField.accessibilityIdentifier =  "newSendOnePay_input_\(text)"
    }

    @objc
    func textFieldChanged(_ textField: UITextField) {
        newTextFieldValue?(textField.text)
    }
}
