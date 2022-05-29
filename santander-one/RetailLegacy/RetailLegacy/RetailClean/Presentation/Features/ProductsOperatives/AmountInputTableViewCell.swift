import UIKit
import CoreFoundationLib

class AmountInputTableViewCell: BaseViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var formattedAmountTextField: FormattedTextField!
    var newTextFieldValue: ((String?) -> Void)?
    @IBOutlet weak var marginHeightConstraint: NSLayoutConstraint!
   
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
            marginHeightConstraint.constant = 0
            return
        }
        titleLabel.set(localizedStylableText: title)
    }
    
    func setAccessibilityIdentifiers(identifiers: AmountInputIdentifiers) {
        setTitleIdentifier(identifiers.title)
        setInputTextIdentifier(identifiers.inputText)
        setInputTextRightImageIdentifier(identifiers.inputRightImage)
    }
    
    func setTitleIdentifier(_ titleIdentifier: String?) {
        setAccessibility { self.titleLabel.isAccessibilityElement = true }
        if let titleIdentifier = titleIdentifier { titleLabel.accessibilityIdentifier = titleIdentifier }
    }
    
    func setInputTextIdentifier(_ inputTextIdentifier: String?) {
        self.formattedAmountTextField.isAccessibilityElement = true
        if let inputTextIdentifier = inputTextIdentifier {
            formattedAmountTextField.accessibilityIdentifier = "\(inputTextIdentifier)_title"
        } else {
            formattedAmountTextField.accessibilityIdentifier = AccessibilityInstantMoney.amountTextField.rawValue
        }
    }
    
    func setInputTextRightImageIdentifier(_ inputTextRightImageIdentifier: String?) {
        formattedAmountTextField.setRightImageIdentifier(identifier: inputTextRightImageIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .uiBackground
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                           font: UIFont.latoBold(size: 16),
                                           textAlignment: .left))
        
        formattedAmountTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        formattedAmountTextField.keyboardType = .decimalPad
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        newTextFieldValue?(textField.text)
    }
}

extension AmountInputTableViewCell: AccessibilityCapable { }
