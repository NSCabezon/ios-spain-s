import UIKit
import CoreFoundationLib

class AmountTextFieldFormatter: NSObject {
    
    private var maximumFractionDigits: Int {
        didSet {
            formatter.maximumFractionDigits = maximumFractionDigits
        }
    }
    private var maximumIntegerDigits: Int {
        didSet {
            formatter.maximumIntegerDigits = maximumIntegerDigits
        }
    }
    private lazy var formatter: NumberFormatter = {
        return formatterForRepresentation(.amountTextField(maximumFractionDigits: maximumFractionDigits, maximumIntegerDigits: maximumIntegerDigits))
    }()
    
    var delegate: ChangeTextFieldDelegate?
    
    init(maximumIntegerDigits: Int = 12, maximumFractionDigits: Int = 2) {
        self.maximumIntegerDigits = maximumIntegerDigits
        self.maximumFractionDigits = maximumFractionDigits
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        defer {
            textField.sendActions(for: .editingChanged)
        }
        guard let oldText = textField.text else {
            return false
        }
        
        var inputString = string.replacingOccurrences(of: ".", with: ",")
        
        guard !(maximumFractionDigits == 0 && inputString == ",") else {
            return false
        }
        
        let validCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ",."))
        
        if textField.text?.contains(formatter.decimalSeparator) == true && (inputString.contains(",") || inputString.contains(".")) {
            return false
        }
        
        if inputString != "", let value = isValidInsertion(text: oldText, insertedString: inputString, insertionPosition: range.location) {
            return value
        }
        
        guard let convertedRange = Range(range, in: oldText) else {
            return false
        }
        inputString = inputString == "," ? formatter.decimalSeparator : inputString
        var newText = oldText.replacingCharacters(in: convertedRange, with: inputString)
        newText = newText.replacingOccurrences(of: formatter.groupingSeparator, with: "")
        newText = newText.replacingOccurrences(of: formatter.decimalSeparator, with: ".")
        newText = filter(text: newText, characterSet: validCharacters)
        
        var separatorsToSelectionOld = 0
        var originalPosition = 0
        originalPosition = range.location
        let s = String(oldText.prefix(originalPosition))
        separatorsToSelectionOld = s.filter({$0 == "."}).count
        
        if newText == "" {
            if string == "" {
                delegate?.willChangeText(textField: textField, text: newText)
                return true
            } else {
                textField.selectedTextRange = correctCaret(in: textField, string: oldText, range: range)
                return false
            }
        }
        
        if newText.hasPrefix(".") {
            newText = "0" + newText
            originalPosition += 1
        }
        
        formatter.alwaysShowsDecimalSeparator = newText.contains(".") && maximumFractionDigits > 0
        if newText.contains("."), let startIndex = newText.firstIndex(of: ".") {
            let decimalsDigits = newText[startIndex...].count - 1
            formatter.minimumFractionDigits = min(decimalsDigits, maximumFractionDigits)
        } else {
            formatter.minimumFractionDigits = 0
        }
        guard let decimalValue = Decimal(string: newText), let formattedText = formatter.string(from: NSDecimalNumber(decimal: decimalValue)) else {
            return false
        }
        delegate?.willChangeText(textField: textField, text: newText)
        textField.text = formattedText
        
        let separatorsToOriginalPositionNew = formattedText.prefix(originalPosition).filter({ $0 == "." }).count
        let newSubstring = formattedText.prefix(originalPosition + inputString.count - (separatorsToSelectionOld - separatorsToOriginalPositionNew))
        
        let separatorsToSelectionNew = newSubstring.filter({ $0 == "."}).count
        let separatorAdjustment = separatorsToSelectionNew - separatorsToSelectionOld
        
        if let newCaretPosition = textField.position(from: textField.beginningOfDocument, offset: originalPosition + separatorAdjustment + inputString.count) {
            textField.selectedTextRange = textField.textRange(from: newCaretPosition, to: newCaretPosition)
        }        
        return false
    }
    
    private func correctCaret(in textField: UITextField, string: String, range: NSRange) -> UITextRange? {
        let isErasing = string.isEmpty && range.length > 0
        let currentCaretPosition = isErasing ? range.location : range.location + string.count - range.length
        
        if let newCaretPosition = textField.position(from: textField.beginningOfDocument, offset: currentCaretPosition) {
            return textField.textRange(from: newCaretPosition, to: newCaretPosition)
        }
        return nil
    }
    
    private func filter(text: String, characterSet: CharacterSet) -> String {
        guard !text.isEmpty else {
            return text
        }
        let validCharacterText = text.filterValidCharacters(characterSet: characterSet)
        return validCharacterText
    }
    
    private func isValidInsertion(text: String, insertedString: String, insertionPosition: Int) -> Bool? {
        
        if let fractionPosition = text.firstIndex(of: formatter.decimalSeparator[formatter.decimalSeparator.startIndex])?.encodedOffset {
            //Check decimal lenght
            if insertionPosition > fractionPosition {
                //check fraction
                if (text.count - fractionPosition) > maximumFractionDigits {
                    return false
                }
            } else if text.prefix(fractionPosition).filter({ $0 != "."}).count >= maximumIntegerDigits {
                return false
            }
        } else if text.filter({ $0 != "."}).count >= maximumIntegerDigits && insertedString != "," {
            return false
        }
        
        return nil
    }
    
}

extension AmountTextFieldFormatter: TextFieldFormatterProtocol {}

extension AmountTextFieldFormatter: TextFieldFormatter {
    func maximumIntegerDigits(value: Int) {
        self.maximumIntegerDigits = value
    }
    
    func maximumFractionDigits(value: Int) {
        self.maximumFractionDigits = value
    }
}
