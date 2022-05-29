//

import UIKit
import CoreFoundationLib

struct IBANTextFieldInfo {
    let country: SepaCountryInfo
    let length: Int?
}

protocol IbanPrefixDelegate: class {
    func updateWithCalculatedPrefix(_ prefix: String)
}

class IBANTextField: KeyboardTextField {
    
    // MARK: - Private attributes
    private var bankingUtils: BankingUtilsProtocol?
    private var formatHandler = IBANTextFieldDelegate()
    fileprivate weak var leftLabel: UILabel?
    
    // MARK: - Public attributes
    
    override var delegate: UITextFieldDelegate? {
        get {
            return formatHandler.delegate
        }
        set {
            formatHandler.delegate = newValue
            super.delegate = formatHandler
        }
    }
    
    var customDelegate: ChangeTextFieldDelegate? {
        get {
            return formatHandler.customDelegate
        }
        set {
            formatHandler.customDelegate = newValue
        }
    }
    
    var info: IBANTextFieldInfo? {
        didSet {
            let controlDigit = fixedControlDigit ?? "XX"
            leftLabel?.text = "\(info?.country.code ?? "")\(controlDigit)"
            keyboardType = keyboardType()
            autocapitalizationType = .allCharacters
            formatHandler.maxLength = length()
            formatHandler.characterSet = characterSet()
        }
    }
    
    var fixedControlDigit: String?
    
    var ccWithCheckDigit: String {
        leftLabel?.text ?? ""
    }
    
    weak var prefixDelegate: IbanPrefixDelegate?
    
    // MARK: - Public methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setBankingUtils(_ bankingUtils: BankingUtilsProtocol) {
        self.bankingUtils = bankingUtils
        formatHandler.characterSet = bankingUtils.textInputAttributes.validCharacterSet
        leftLabel?.text = "\(bankingUtils.countryCode ?? "")XX"
        autocapitalizationType = .allCharacters
        keyboardType = bankingUtils.textInputAttributes.keyboardType
    }
    
    func applyStyle(_ stylist: TextFieldStylist) {
        stylist.performStyling(self)
        leftLabel?.applyStyle(LabelStylist(textColor: stylist.textColor, font: stylist.font, textAlignment: .center))
    }
    
    func length() -> Int? {
        return bankingUtils?.textInputAttributes.bbaLenght ?? BankingUtils.maxIbanLength
    }
    
    func copyText(text: String) {
        let pastedText = formatHandler.handlePastedString(in: self, replacementString: text)
        self.text = pastedText
        self.handleIBANTextFieldChanges(withFutureText: pastedText)
    }
    
    // MARK: - Private methods
    
    private func setup() {
        let view = UIView()
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leftLabel = label
        leftView = view
        leftViewMode = .always
        if #available(iOS 11.0, *) {
            smartInsertDeleteType = .no
        }
    }
    
    private func characterSet() -> CharacterSet {
        return info?.country.code == "ES" ? CharacterSet(charactersIn: "1234567890") : .iban
    }
    
    private func keyboardType() -> UIKeyboardType {
        return info?.country.code == "ES" ? .numberPad : .default
    }
}

private class IBANTextFieldDelegate: FormattedCustomTextField {
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let ibanTextField = textField as? IBANTextField else { return false }
        let shouldChangeCharacters = super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        let newText: String
        if shouldChangeCharacters {
            // if the textfield returns that everything was fine
            let util = (textField.text ?? "") as NSString
            newText = util.replacingCharacters(in: range, with: string) as String
        } else if let pastedString = UIPasteboard.general.string, pastedString == string {
            // in case the textfield returns that something went wrong, we have to check the pasted text
            let pastedText = handlePastedString(in: ibanTextField, replacementString: string)
            textField.text = pastedText
            newText = pastedText
        } else {
            newText = textField.text ?? ""
        }
        ibanTextField.customDelegate?.willChangeText(textField: ibanTextField, text: newText)

        var additionalCondition = true
        let isErasing = string.isEmpty && range.length > 0
        let currentCaretPosition = isErasing ? range.location : range.location + string.count - range.length

        additionalCondition = ibanTextField.handleIBANTextFieldChanges(withFutureText: newText, caretPosition: currentCaretPosition)
        
        ibanTextField.customDelegate?.willChangeText(textField: ibanTextField, text: newText)
        ibanTextField.prefixDelegate?.updateWithCalculatedPrefix(ibanTextField.leftLabel?.text ?? "")

        return additionalCondition && shouldChangeCharacters
    }
    
    // MARK: - Handle methods
    
    /// Returns the string pasted filtered by characterSet and length (starting by rigth)
    ///
    /// - Parameters:
    ///   - textField: the IBANTextField
    ///   - string: the string pasted
    /// - Returns: the string filtered
    func handlePastedString(in textField: IBANTextField, replacementString string: String) -> String {
        guard textField.isValidPastedText(string) else {
            return ""
        }
        guard let length = textField.length() else {
            return textField.text ?? ""
        }
        let filteredString = string.filterValidCharacters(characterSet: characterSet)
        if filteredString.count > length {
            return filteredString.substring(filteredString.count - length) ?? textField.text ?? ""
        }
        return textField.text ?? ""
    }
}

private extension IBANTextField {
    @discardableResult
    func handleIBANTextFieldChanges(withFutureText text: String, caretPosition: Int? = nil) -> Bool {
        guard let countryCode = bankingUtils?.countryCode, let lenght = self.length()  else { return true }
        if text.count == lenght {
            if let controlDigit = fixedControlDigit {
                self.leftLabel?.text = "\(countryCode)\(controlDigit)"
            } else {
                let checkDigit = bankingUtils?.calculateCheckDigit(bban: text, countryCode: countryCode) ?? ""
                self.leftLabel?.text = "\(countryCode)\(checkDigit.isEmpty ? "XX" : checkDigit)"
            }
            // workaround to fix caret position when full iban is pasted
            if caretPosition == 24, let newCaretPosition = self.position(from: self.endOfDocument, offset: 0) {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.selectedTextRange = self.textRange(from: newCaretPosition, to: newCaretPosition)
                }
            }
            return true

        } else {
            let controlDigit = fixedControlDigit ?? "XX"
            self.leftLabel?.text = "\(countryCode)\(controlDigit)"
            return text.count <= lenght
        }
    }
    
    func isValidPastedText(_ text: String) -> Bool {
        guard let countryCode = self.info?.country.code else { return false }
        let countryCodeCandidate = text.prefix(2).description
        
        if (countryCodeCandidate.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil &&
              countryCodeCandidate == countryCode)
            || (bankingUtils?.textInputAttributes.bbaLenght == text.count) { return true }
        return false
    }
}
