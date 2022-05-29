import UIKit

class NumericTextFieldFormatter: NSObject {
    private var maximumIntegerDigits: Int {
        didSet {
            formatter.maximumIntegerDigits = maximumIntegerDigits
        }
    }
    private lazy var formatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.alwaysShowsDecimalSeparator = false
        formatter.usesGroupingSeparator = false
        formatter.minimumIntegerDigits = 0
        formatter.maximumIntegerDigits = maximumIntegerDigits
        formatter.roundingMode = .down
        return formatter
    }()
    
    weak var delegate: ChangeTextFieldDelegate?
    
    init(maximumIntegerDigits: Int = 13) {
        self.maximumIntegerDigits = maximumIntegerDigits
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        defer {
            textField.sendActions(for: .editingChanged)
        }
        guard let oldText = textField.text, let convertedRange = Range(range, in: oldText) else {
            return false
        }
        
        let newText = oldText.replacingCharacters(in: convertedRange, with: string).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")
        
        if textField.text?.contains(",") == true && (newText.contains(",") || newText.contains(".")) {
            return false
        }
        
        if newText.count <= maximumIntegerDigits {
            delegate?.willChangeText(textField: textField, text: newText)
            textField.text = newText
        }
        return false
    }
}

extension NumericTextFieldFormatter: TextFieldFormatterProtocol {}

extension NumericTextFieldFormatter: TextFieldFormatter {
    func maximumIntegerDigits(value: Int) {
        self.maximumIntegerDigits = value
    }
}
