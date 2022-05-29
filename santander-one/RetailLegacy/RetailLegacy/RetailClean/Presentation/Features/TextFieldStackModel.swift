import UIKit

protocol InputEditableIdentificable {
    var inputIdentifier: String { get }
    func setCurrentValue(_ value: String)
}

class TextFieldStackModel: StackItem<TextFieldStackView>, InputIdentificable, InputEditableIdentificable {
    let inputIdentifier: String
    private(set) var dataEntered: String?
    private let placeholder: LocalizedStylableText?
    private let maxLength: Int?
    private let type: KeyboardTextFieldResponderOrder?
    private var setTextFieldValue: ((String?) -> Void)?
    private var characterSet: CharacterSet?
    
    init(inputIdentifier: String, placeholder: LocalizedStylableText? = nil, insets: Insets = Insets(left: 10, right: 10, top: 0, bottom: 8), maxLength: Int? = nil, nextType: KeyboardTextFieldResponderOrder? = nil, characterSet: CharacterSet? = nil) {
        self.placeholder = placeholder
        self.inputIdentifier = inputIdentifier
        self.type = nextType
        self.maxLength = maxLength
        self.characterSet = characterSet
        super.init(insets: insets)
    }
    
    override func bind(view: TextFieldStackView) {
        view.setText(text: dataEntered)
        view.textField.formattedDelegate.maxLength = maxLength
        view.styledPlaceholder = placeholder
        setTextFieldValue = view.setTextFieldValue
        view.textField.formattedDelegate.characterSet = characterSet ?? CharacterSet.custom
        view.newTextFieldValue = { [weak self] value in
            self?.dataEntered = value?.isEmpty == true ? nil : value
        }
        if let type = type {
            view.textField.reponderOrder = type
        }
    }
    
    func setCurrentValue(_ value: String) {
        dataEntered = value
        setTextFieldValue?(value)
    }
}
