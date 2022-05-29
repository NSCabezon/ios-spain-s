import UIKit
import CoreFoundationLib

public class LimitedTextField: UITextField {
    let realDelegate = LimitedTextFieldDelegate()
    
    override public var delegate: UITextFieldDelegate? {
        get {
            return realDelegate.delegate
        }
        set {
            realDelegate.delegate = newValue
            super.delegate = realDelegate
        }
    }
    
    public func configure(maxLength: Int?, characterSet: CharacterSet? = nil, onlyCheckCharactersInTheReplacementString: Bool = false) {
        realDelegate.maxLength = maxLength
        realDelegate.onlyCheckCharactersInTheReplacementString = onlyCheckCharactersInTheReplacementString
        if let characterSet = characterSet {
            realDelegate.characterSet = characterSet
        }
    }
}

class LimitedTextFieldDelegate: NSObject, UITextFieldDelegate {
    var characterSet: CharacterSet = CharacterSet.alphanumerics
    var maxLength: Int?
    var onlyCheckCharactersInTheReplacementString: Bool = false
    weak var delegate: UITextFieldDelegate?
    
    private func filterValidCharacters(text: String) -> Bool {
        guard !text.isEmpty else { return true }
        return !text.unicodeScalars.contains(where: { !characterSet.contains($0) })
    }
}

extension LimitedTextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let maxLength = maxLength else { return true }
        guard let text = textField.text, let newRange = Range(range, in: text) else { return false }
        let substring = text[newRange]
        let count = text.count - substring.count + string.count
        return count <= maxLength && (onlyCheckCharactersInTheReplacementString ? true : filterValidCharacters(text: text)) && filterValidCharacters(text: string) && delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        delegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldClear?(textField) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn?(textField) ?? false
    }
}
