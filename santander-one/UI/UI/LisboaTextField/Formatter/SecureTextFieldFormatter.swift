import CoreFoundationLib

public enum SecureState {
    case char
    case secure
}

public final class SecureTextFieldFormatter: NSObject, TextFieldFormatter {
    public weak var delegate: UITextFieldDelegate?
    public weak var customDelegate: ChangeTextFieldDelegate?
    public var customValidatorDelegate: TextFieldValidatorProtocol?
    private let maxLength: Int?
    private let fillAllView: Bool
    private var textField: UITextField = UITextField()
    private var hiddenText: String = "" {
        didSet {
            if hiddenText.count > maxLength ?? 8 {
                hiddenText = ""
            }
        }
    }
    private var state: SecureState = .secure
    
    public init(maxLength: Int? = 8, state: SecureState = .secure, fillAllView: Bool = false, customTextValidatorDelegate: TextFieldValidatorProtocol? = nil) {
        self.maxLength = maxLength
        self.state = state
        self.fillAllView = fillAllView
        self.customValidatorDelegate = customTextValidatorDelegate
    }
    
    public func changeFormatter(state: SecureState) {
        self.state = state
        self.updatePassword()
    }
}

private extension SecureTextFieldFormatter {
    func updatePassword() {
        let array = Array(self.hiddenText)
        self.textField.text = array.reduce("", { return $0 + (self.state == .secure ? "•" : String($1)) })
        if self.fillAllView {
            let correction: CGFloat = Screen.isIphone4or5 ? 4.0 : 0.0
            self.textField.font = UIFont.santander(family: .text, type: .regular, size: (array.isEmpty ? 20 - correction : (self.state == .secure ? 50.0 - correction : 20.0 - correction)))
            
            guard let font = self.textField.font else { return }
            let charSpace = (self.state == .secure ? "•" : "9").size(withAttributes: [NSAttributedString.Key.font: font]).width
            
            let total = charSpace * CGFloat(self.maxLength ?? 8 + 1) + 10
            if self.textField.frame.width - total > 0.0 {
                self.textField.defaultTextAttributes.updateValue((array.isEmpty ? 0.2 : (self.textField.frame.width - total) / CGFloat(self.maxLength ?? 8 - 1)),
                                                            forKey: NSAttributedString.Key.kern)
            }
        }
    }
}

extension SecureTextFieldFormatter: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        defer {
            textField.sendActions(for: .editingChanged)
        }
        self.textField = textField
        guard string != " " else { return false }
        if  let emojiDelegate = customValidatorDelegate, emojiDelegate.isEmoji(string) {
            return false }
        let currentText = hiddenText
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        guard updatedText.count <= maxLength ?? 8 else { return false }
        self.hiddenText = updatedText
        self.updatePassword()
        self.customDelegate?.willChangeText(textField: textField, text: self.hiddenText)
        return false
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing?(textField)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    @available(iOS 10.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        delegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn?(textField) ?? false
    }
}
