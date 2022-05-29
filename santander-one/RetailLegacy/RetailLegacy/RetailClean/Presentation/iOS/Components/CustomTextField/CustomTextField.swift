//

import UIKit

public protocol ChangeTextFieldDelegate: class {
    func willChangeText(textField: UITextField, text: String)
}

public class CustomTextField: KeyboardTextField {
    public let formattedDelegate = FormattedCustomTextField()
    public var customDelegate: ChangeTextFieldDelegate? {
        get {
            return formattedDelegate.customDelegate
        }
        set {
            formattedDelegate.customDelegate = newValue
        }
    }
    
    public override var delegate: UITextFieldDelegate? {
        get {
            return formattedDelegate.delegate
        }
        set {
            formattedDelegate.delegate = newValue
            if let customDelegate = newValue as? ChangeTextFieldDelegate {
                formattedDelegate.customDelegate = customDelegate
            }
            super.delegate = formattedDelegate
        }
    }
}

public class FormattedCustomTextField: NSObject {
    
    var characterSet = CharacterSet.custom
    public var maxLength: Int?
    weak var delegate: UITextFieldDelegate?
    weak var customDelegate: ChangeTextFieldDelegate?
    
    func filter(text: String) -> String {
        guard !text.isEmpty else {
            return text
        }
        let validCharacterText = text.filterValidCharacters(characterSet: characterSet)
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

extension FormattedCustomTextField: UITextFieldDelegate {
   public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let util = (textField.text ?? "") as NSString
        let text = util.replacingCharacters(in: range, with: string) as String
        
        let textFiltered = filter(text: text)
        customDelegate?.willChangeText(textField: textField, text: textFiltered)
        var exit = true
        
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
