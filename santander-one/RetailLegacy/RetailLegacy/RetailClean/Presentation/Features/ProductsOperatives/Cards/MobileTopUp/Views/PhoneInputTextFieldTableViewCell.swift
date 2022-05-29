import UIKit

class PhoneInputTextFieldTableViewCell: BaseViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: PhoneTextField!
    var newTextFieldValue: ((String?) -> Void)?
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func setTitleIdentifier(_ titleIdentifier: String?) {
        titleLabel.accessibilityIdentifier = titleIdentifier
    }
    
    func setInputTextIdentifier(_ inputTextIdentifier: String?) {
        inputTextField.accessibilityIdentifier = inputTextIdentifier
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .uiBackground
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                font: UIFont.latoBold(size: 16),
                                textAlignment: .left))
        inputTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .allEditingEvents)
        inputTextField.keyboardType = .phonePad
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        newTextFieldValue?(textField.text)
    }
}
