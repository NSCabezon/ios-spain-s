import UIKit

class PercentageTextFieldFormatter: NSObject, TextFieldFormatter, TextFieldFormatterProtocol {
    private let percentageTest = NSPredicate(format: "SELF MATCHES %@", "(^100)$|(^\\d{0,2}([.|,]\\d{0,2})?)")
    var delegate: ChangeTextFieldDelegate?
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let convertedRange = Range(range, in: oldText) else {
            return false
        }
        
        var newText = oldText.replacingCharacters(in: convertedRange, with: string).replacingOccurrences(of: ".", with: ",")
        
        let parts = newText.components(separatedBy: ",")
        
        if (parts.count == 1 && newText.count > 1 && newText.hasPrefix("0")) || (parts.count == 2 && parts[0].count > 1 && parts[0].hasPrefix("0")) {
            newText.removeFirst()
            delegate?.willChangeText(textField: textField, text: newText)
            textField.text = newText
            
        } else if percentageTest.evaluate(with: newText) {
            delegate?.willChangeText(textField: textField, text: newText)
            textField.text = newText
        }
        
        return false
    }
}
