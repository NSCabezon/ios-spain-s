import UIKit
import CoreFoundationLib

class AmountInputStackView: StackItemView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var formattedAmountTextField: FormattedTextField!
    var newTextFieldValue: ((String?) -> Void)?
    
    var dataEntered: String? {
        didSet {
            formattedAmountTextField.text = dataEntered
        }
    }
    
    var textFormatMode: FormattedTextField.FormatMode? {
        didSet {
            guard let formatMode = textFormatMode else { return }
            formattedAmountTextField.textFormatMode = formatMode
        }
    }
    
    var style: TextFieldStylist? {
        didSet {
            guard let style = style else { return }
            (formattedAmountTextField as UITextField).applyStyle(style)
        }
    }
    
    func setTitle(_ title: LocalizedStylableText?) {
        guard let title = title else {
            titleLabel.text = nil
            titleLabel.accessibilityIdentifier = AccessibilityInternalTransferAmount.labelAmount.rawValue
            return
        }
        titleLabel.set(localizedStylableText: title)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                           font: UIFont.latoBold(size: 16),
                                           textAlignment: .left))
        
        formattedAmountTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        formattedAmountTextField.keyboardType = .decimalPad
        formattedAmountTextField.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputAmount.rawValue
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        newTextFieldValue?(textField.text)
    }
}
