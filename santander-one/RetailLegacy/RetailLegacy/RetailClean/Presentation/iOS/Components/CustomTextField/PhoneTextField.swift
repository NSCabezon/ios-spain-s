//

import UIKit

class PhoneTextField: KeyboardTextField {
    private let formattedDelegate = PhoneFormattedCustomTextField()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        keyboardType = .phonePad
        autocorrectionType = .no
    }
    
    override var delegate: UITextFieldDelegate? {
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

class PhoneFormattedCustomTextField: FormattedCustomTextField {
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
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range == NSRange(location: 0, length: 0) && string == " " {
            // Phone number autofill was selected by user
            return true
        }
        guard var number = textField.text else { return false }
        
        //If text is deleting.
        if string.isEmpty {
            if range.location == 0 && number.contains("+") {
                let util = (textField.text ?? "") as NSString
                let text = util.replacingCharacters(in: range, with: string) as String
                customDelegate?.willChangeText(textField: textField, text: text)
                return true
                
            } else if range.length > 0 {
                return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
            }
        }
        
        // If more than one + or in wrong position
        if string == "+" && (range.location > 0 || number.contains("+")) { return false }
        
        number = number.replace(" ", "")
        
        guard let match = getFilter(text: number) else { return false }
        
        let areaCode = getAreaCode(text: number, match: match)
        let phone = getPhone(text: number, indexes: [6, 7, 8], match: match)
        
        //If phone already full
        if range.length > 0 || ((areaCode.isEmpty || !areaCode.contains("+")) && range.location <= areaCode.count) || phone.count < 11 {
            return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        return false
    }
}
