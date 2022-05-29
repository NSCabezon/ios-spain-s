import UIKit

class SecureTextFieldViewModel: TableModelViewItem<SecureTextFieldTableViewCell>, InputIdentificable {
    private let title: LocalizedStylableText
    let inputIdentifier: String
    var dataEntered: String?
    private let keyboardType: UIKeyboardType
    private let characterSet: CharacterSet
    var actionClosure: ((Bool) -> Void)?
    private let accesibilityIds: SecureTextFielAccesibilityIds?
    
    init(inputIdentifier: String, titleInfo: LocalizedStylableText, keyboardType: UIKeyboardType, characterSet: CharacterSet, dependencies: PresentationComponent, accesibilityIds: SecureTextFielAccesibilityIds? = nil) {
        self.title = titleInfo
        self.dataEntered = ""
        self.inputIdentifier = inputIdentifier
        self.keyboardType = keyboardType
        self.characterSet = characterSet
        self.accesibilityIds = accesibilityIds
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: SecureTextFieldTableViewCell) {
        viewCell.setTitle(title)
        viewCell.newTextFieldValue = { [weak self] newValue in
            self?.dataEntered = newValue
        }
        viewCell.textField.maxLength = 8
        viewCell.textField.text = self.dataEntered
        viewCell.textField.keyboardType = self.keyboardType
        viewCell.textField.characterSet = self.characterSet
        viewCell.textField.actionClosure = actionClosure
        viewCell.titleLabel.accessibilityIdentifier = accesibilityIds?.title
        viewCell.textField.accessibilityIdentifier = accesibilityIds?.textField
    }
}

struct SecureTextFielAccesibilityIds {
    let title: String?
    let textField: String?
}
