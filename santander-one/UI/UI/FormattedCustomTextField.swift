import CoreFoundationLib

public class UIFormattedCustomTextField: NSObject, TextFieldFormatter {
    var maxLength: Int?
    weak public var delegate: UITextFieldDelegate?
    weak public var customDelegate: ChangeTextFieldDelegate?
    private var allowOnlyCharacterSet: CharacterSet = CharacterSet.operative

    public func setMaxLength(maxLength: Int) {
        self.maxLength = maxLength
    }
    
    public func setAllowOnlyCharacters(_ characterSet: CharacterSet) {
        self.allowOnlyCharacterSet = characterSet
    }
    
    func filter(text: String) -> String {
        guard !text.isEmpty else {
            return text
        }
        let validCharacterText = text.filterValidCharacters(characterSet: allowOnlyCharacterSet)
        let validText = filterMaxSize(text: validCharacterText)
        return validText
    }
    
    func filterMaxSize(text: String, maxSize: Int = 255) -> String {
        guard let textFiltered = text.substring(0, min(maxLength ?? maxSize, text.count)) else {
            return text
        }
        return textFiltered
    }
}

extension UIFormattedCustomTextField: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let util = (textField.text ?? "") as NSString
        let text = util.replacingCharacters(in: range, with: string) as String
        
        let textFiltered = filter(text: text)
        customDelegate?.willChangeText(textField: textField, text: textFiltered)
        var exit = true
        
        let character = CharacterSet(charactersIn: string)
        exit = allowOnlyCharacterSet.isSuperset(of: character)

        if textFiltered != text {
            let count = textField.text?.count ?? 0
            let notIsInsertAtEnd = range.length != 0 || count != range.location
            textField.text = textFiltered
            
            if notIsInsertAtEnd, let newCaretPosition = textField.position(from: textField.beginningOfDocument, offset: range.location + string.count) {
                textField.selectedTextRange = textField.textRange(from: newCaretPosition, to: newCaretPosition)
            }
            exit = false
        }

        return exit
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
