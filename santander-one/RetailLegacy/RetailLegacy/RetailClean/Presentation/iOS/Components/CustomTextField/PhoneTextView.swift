import UIKit
import UI

class PhoneTextView: KeyboardTextView {
    private let formattedDelegate = PhoneFormattedCustomTextView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        keyboardType = .phonePad
    }
    
    override var delegate: UITextViewDelegate? {
        get {
            return super.delegate
        }
        set {
            formattedDelegate.delegate = newValue
            if let customDelegate = newValue as? ChangeTextViewDelegate {
                formattedDelegate.customDelegate = customDelegate
            }
            super.delegate = formattedDelegate
        }
    }
}

class PhoneFormattedCustomTextView: FormattedCustomTextView {
    private let pattern: String = "((\\+0*[1-9]?[0-9]?)|(\\(\\+?0*[1-9]?[0-9]*\\)?)|(0+[1-9]?[0-9]?))?0*(([1-9][0-9]{0,2})([0-9][0-9]{0,2})?([0-9][0-9]{0,2})?)?"
    
    override init() {
        super.init()
        setupCharacterSet()
    }
    
    func setupCharacterSet() {
        characterSet = CharacterSet(charactersIn: "1234567890()+")
    }
    /*
     0: Total
     1: Prefix
     2: Prefix(+)
     3: Prefix(“()”)
     4: Prefix(0)
     5: Tlf Complete
     6: Tlf Group 1
     7: Tlf Group 2
     8: Tlf Group 3
     */
    override func filter(text: String) -> String {
        guard !text.isEmpty else {
            return text
        }
        let validCharacterText = text.filterValidCharacters(characterSet: characterSet)
        let validSizeText = filterMaxSize(text: validCharacterText, maxSize: 20)
        let validText = filterByRegularExpression(text: validSizeText)
        return validText
    }
    
    private func getRange(text: String, index: Int, match: NSTextCheckingResult) -> String? {
        guard match.numberOfRanges > index - 1 else {
            return nil
        }
        let range = match.range(at: index)
        if range.location != NSNotFound {
            let result = text.substring(with: range)
            return result
        } else {
            return nil
        }
    }
    
    private func getAreaCode(text: String, match: NSTextCheckingResult) -> String {
        guard let prefix = getRange(text: text, index: 1, match: match) else {
            return ""
        }
        return prefix
    }
    
    private func getPhone(text: String, indexes: [Int], match: NSTextCheckingResult) -> String {
        var formattedText = ""
        for index in indexes {
            if let phone = getRange(text: text, index: index, match: match) {
                if indexes.first != index {
                    formattedText += " "
                }
                formattedText += phone
            } else {
                break
            }
        }
        return formattedText
    }
    
    private func getFilter(text: String) -> NSTextCheckingResult? {
        do {
            let regularExpression = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: text.count)
            let matches = regularExpression.matches(in: text, options: [], range: range)
            return matches.first
        } catch {}
        return nil
    }
    
    private func filterByRegularExpression(text: String) -> String {
        guard let match = getFilter(text: text) else {
            return ""
        }
        var formattedText = getAreaCode(text: text, match: match)
        
        let phone = getPhone(text: text, indexes: [6, 7, 8], match: match)
        if phone.count > 0 && formattedText.count > 0 {
            formattedText += " "
        }
        formattedText += phone
        return formattedText
    }
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard var number = textView.text else { return false }
        //If text is deleting.
        if text.isEmpty {
            if range.location == 0 && number.contains("+") {
                let util = (textView.text ?? "") as NSString
                let textReplaced = util.replacingCharacters(in: range, with: text) as String
                customDelegate?.willChangeText(textView: textView, text: textReplaced)
                return true
                
            } else if range.length > 0 {
                return super.textView(textView, shouldChangeTextIn: range, replacementText: text)
            }
        }
        
        // If more than one + or in wrong position
        if text == "+" && (range.location > 0 || number.contains("+")) { return false }
        
        number = number.replace(" ", "")
        
        guard let match = getFilter(text: number) else { return false }
        
        let areaCode = getAreaCode(text: number, match: match)
        let phone = getPhone(text: number, indexes: [6, 7, 8], match: match)
        
        //If phone already full
        if range.length > 0 || ((areaCode.isEmpty || !areaCode.contains("+")) && range.location <= areaCode.count) || phone.count < 11 {
            return super.textView(textView, shouldChangeTextIn: range, replacementText: text)
        }
        return false
    }
}
