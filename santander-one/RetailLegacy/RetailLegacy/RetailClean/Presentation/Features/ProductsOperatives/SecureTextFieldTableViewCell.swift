//

import UIKit

class SecureTextFieldTableViewCell: BaseViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: SecureTextField!
    var newTextFieldValue: ((String?) -> Void)?
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .uiBackground
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0)))
        (textField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoMedium(size: 16.0), textAlignment: .left))
        textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingDidEnd)
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        newTextFieldValue?(textField.text)
    }
    
}
