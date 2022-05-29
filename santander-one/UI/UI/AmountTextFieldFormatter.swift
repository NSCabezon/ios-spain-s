import UIKit
import CoreFoundationLib

public protocol ChangeTextFieldDelegate: AnyObject {
    func willChangeText(textField: UITextField, text: String)
}

public protocol TextFieldFormatter: UITextFieldDelegate {
    var delegate: UITextFieldDelegate? { get set }
    var customDelegate: ChangeTextFieldDelegate? { get set }
}

public class UIAmountTextFieldFormatter: NSObject, TextFieldFormatter {
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
    private var groupingSeparator: String {
        self.formatter.groupingSeparator
    }
    private var decimalSeparator: String {
        self.formatter.decimalSeparator
    }
    private lazy var formatter: NumberFormatter = {
        return formatterForRepresentation(.amountTextField(maximumFractionDigits: maximumFractionDigits, maximumIntegerDigits: maximumIntegerDigits))
    }()

    weak public var delegate: UITextFieldDelegate?
    weak public var customDelegate: ChangeTextFieldDelegate?
    
    public init(maximumIntegerDigits: Int = 12, maximumFractionDigits: Int = 2) {
        self.maximumIntegerDigits = maximumIntegerDigits
        self.maximumFractionDigits = maximumFractionDigits
        super.init()
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
        if let fractionPosition = text.indexes(of: self.decimalSeparator).first {
            // Check decimal lenght
            if insertionPosition > fractionPosition, (text.count - fractionPosition) > self.maximumFractionDigits {
                return false
            } else if insertionPosition <= fractionPosition, text.prefix(fractionPosition).filter({ $0 != self.groupingSeparator.first }).count >= self.maximumIntegerDigits {
                return false
            }
        } else if text.filter({ $0 != self.groupingSeparator.first }).count >= self.maximumIntegerDigits && insertedString != self.decimalSeparator {
            return false
        }
        
        return nil
    }
    
}

extension UIAmountTextFieldFormatter: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        defer {
            textField.sendActions(for: .editingChanged)
        }
        guard let oldText = textField.text else {
            return false
        }
        
        let inputString = string.replacingOccurrences(of: ".", with: self.decimalSeparator)
            .replacingOccurrences(of: ",", with: self.decimalSeparator)

        guard !(self.maximumFractionDigits == 0 && inputString == self.decimalSeparator) else {
            return false
        }

        let validCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ",.\(self.groupingSeparator)\(self.decimalSeparator)"))

        if textField.text?.contains(self.decimalSeparator) == true && inputString.contains(self.decimalSeparator) {
            return false
        }

        if inputString != "", let value = self.isValidInsertion(text: oldText, insertedString: inputString, insertionPosition: range.location) {
            return value
        }
        
        guard let convertedRange = Range(range, in: oldText) else {
            return false
        }
        var newText = oldText.replacingCharacters(in: convertedRange, with: inputString)
            .replacingOccurrences(of: self.groupingSeparator, with: "")
            .replacingOccurrences(of: self.decimalSeparator, with: ".")
        newText = self.filter(text: newText, characterSet: validCharacters)
        newText = filterDigitsOfIntegerPart(newText, separator: ".")
        var separatorsToSelectionOld = 0
        var originalPosition = range.location
        let oldTextPrefixed = String(oldText.prefix(originalPosition))
        separatorsToSelectionOld = oldTextPrefixed.filter({$0 == self.groupingSeparator.first}).count

        if newText == "" {
            if string == "" {
                customDelegate?.willChangeText(textField: textField, text: newText)
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
        
        self.formatter.alwaysShowsDecimalSeparator = newText.contains(".") && self.maximumFractionDigits > 0
        if newText.contains("."), let startIndex = newText.firstIndex(of: ".") {
            let decimalsDigits = newText[startIndex...].count - 1
            self.formatter.minimumFractionDigits = min(decimalsDigits, self.maximumFractionDigits)
        } else {
            self.formatter.minimumFractionDigits = 0
        }
        guard let decimalValue = Decimal(string: newText), let formattedText = self.formatter.string(from: NSDecimalNumber(decimal: decimalValue)) else {
            return false
        }
        
        self.customDelegate?.willChangeText(textField: textField, text: newText)
        textField.text = formattedText

        let separatorsToOriginalPositionNew = formattedText.prefix(originalPosition).filter({ $0 == self.groupingSeparator.first }).count
        let newSubstring = formattedText.prefix(originalPosition + inputString.count - (separatorsToSelectionOld - separatorsToOriginalPositionNew))
        
        let separatorsToSelectionNew = newSubstring.filter({ $0 == self.groupingSeparator.first }).count
        let separatorAdjustment = separatorsToSelectionNew - separatorsToSelectionOld
        
        if let newCaretPosition = textField.position(from: textField.beginningOfDocument, offset: originalPosition + separatorAdjustment + inputString.count) {
            textField.selectedTextRange = textField.textRange(from: newCaretPosition, to: newCaretPosition)
        }

        return false
    }
    
    private func filterDigitsOfIntegerPart(_ text: String, separator: String) -> String {
        let textSplitArr = text.components(separatedBy: separator)
        guard textSplitArr.indices.count > 0 else { return text }
        let integerPart = textSplitArr[0]
        if integerPart.count > self.maximumIntegerDigits {
            return integerPart.substring(0, self.maximumIntegerDigits) ?? text
        } else {
            return text
        }
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

extension UIAmountTextFieldFormatter {
    public func formatAmount (fromString string: String?) -> Decimal? {
        guard let optionalString = string else {
            return nil
        }
        let decimalValue = String(optionalString)
        return decimalValue.stringToDecimal
    }
}
