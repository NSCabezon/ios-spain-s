import UIKit

protocol ChangeTextViewDelegate: class {
    func willChangeText(textView: UITextView, text: String)
}

class FormattedCustomTextView: NSObject {
    
    var characterSet = CharacterSet.custom
    var maxLength: Int?
    weak var delegate: UITextViewDelegate?
    weak var customDelegate: ChangeTextViewDelegate?
    
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

extension FormattedCustomTextView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let util = (textView.text ?? "") as NSString
        let text = util.replacingCharacters(in: range, with: text) as String
        let textFiltered = filter(text: text)
        customDelegate?.willChangeText(textView: textView, text: textFiltered)
        if textFiltered == text {
            return true
        } else {
            let count = textView.text?.count ?? 0
            let notIsInsertAtEnd = range.length != 0 || count != range.location
            textView.text = textFiltered
            if notIsInsertAtEnd, let newCaretPosition = textView.position(from: textView.beginningOfDocument, offset: range.location + text.count) {
                textView.selectedTextRange = textView.textRange(from: newCaretPosition, to: newCaretPosition)
            }
            return false
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.textViewShouldBeginEditing?(textView) ?? true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing?(textView)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing?(textView)
    }
}
