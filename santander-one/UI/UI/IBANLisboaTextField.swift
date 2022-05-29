//
//  IBANLisboaTextField.swift
//  UI
//
//  Created by David Gálvez Alonso on 29/05/2020.
//

import CoreFoundationLib

public class IBANLisboaTextField: LisboaTextfield {
    @IBOutlet private weak var leftLabel: UILabel!
    private var characterSet: CharacterSet?
    private let formattedCustomTextField = UIFormattedCustomTextField()
    private weak var bankingUtils: BankingUtilsProtocol?
    public var fixedControlDigit: String?
    public weak var delegate: ChangeTextFieldDelegate?

    public var countryAndCheckDigit: String {
        return leftLabel.text ?? ""
    }
    // MARK: - Public methods
    
    public func setBankingUtils(_ bankingUtils: BankingUtilsProtocol) {
        self.bankingUtils = bankingUtils
        self.characterSet = bankingUtils.textInputAttributes.validCharacterSet
        self.leftLabel.text = "\(bankingUtils.countryCode ?? "")\(fixedControlDigit ?? "XX")"
        self.leftLabel.isHidden = leftLabel.text?.isEmpty ?? true
        self.field.autocapitalizationType = .allCharacters
        self.field.keyboardType = bankingUtils.textInputAttributes.keyboardType
        self.formattedCustomTextField.setAllowOnlyCharacters(bankingUtils.textInputAttributes.validCharacterSet)
        self.formattedCustomTextField.maxLength = bankingUtils.textInputAttributes.bbaLenght
        self.field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var length: Int? {
        return bankingUtils?.textInputAttributes.bbaLenght ?? BankingUtils.maxIbanLength
    }
    
    public func copyText(text: String) {
        let pastedText = handlePastedString(replacementString: text)
        self.updateData(text: pastedText)
        self.field.textColor = .lisboaGray
        self.handleIBANTextFieldChanges(withFutureText: pastedText)
    }
    
    override func setAccessibility() {
        super.setAccessibility()
        field.accessibilityLabel = (field.accessibilityLabel ?? "") + " \(leftLabel.text ?? "")"
        leftLabel.accessibilityElementsHidden = true
    }
}

// MARK: - Private methods

private extension IBANLisboaTextField {
    
    func setup() {
        leftLabel.setSantanderTextFont(type: .regular, size: 17, color: .lisboaGray)
    }
    
    func getCharacterSet() -> CharacterSet {
        return bankingUtils?.textInputAttributes.validCharacterSet ?? CharacterSet.alphanumerics
    }
    
    func keyboardType() -> UIKeyboardType {
        return bankingUtils?.textInputAttributes.keyboardType ?? .default
    }
    
    func isValidPastedText(_ text: String) -> Bool {
        guard let countryCode = bankingUtils?.countryCode else { return false }
        let countryCodeCandidate = text.prefix(2).description
        
        if (countryCodeCandidate.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil &&
              countryCodeCandidate == countryCode)
            || (bankingUtils?.textInputAttributes.bbaLenght == text.notWhitespaces().count) { return true }
        return false
    }
    
    func manageCompleteText(text: String, countryCode: String, caretPosition: Int?) {
        let checkDigit = bankingUtils?.calculateCheckDigit(bban: text) ?? ""
        if let fixedCheckDigit = bankingUtils?.textInputAttributes.checkDigit,
           bankingUtils?.selectedCountryMatchAppCountry == true {
            guard checkDigit == fixedCheckDigit else { return }
        }
        self.leftLabel?.text = "\(countryCode)\(checkDigit.isEmpty ? "XX" : checkDigit)"
        // workaround to fix caret position when full iban is pasted
        if caretPosition == 24, let newCaretPosition = self.field.position(from: self.field.endOfDocument, offset: 0) {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.field.selectedTextRange = self.field.textRange(from: newCaretPosition, to: newCaretPosition)
            }
        }
    }
}

extension IBANLisboaTextField {

    override public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        defer {
            textField.sendActions(for: .editingChanged)
        }
        let shouldChangeCharacters = formattedCustomTextField.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        let newText: String
        if shouldChangeCharacters {
            // if the textfield returns that everything was fine
            let util = (textField.text ?? "") as NSString
            newText = util.replacingCharacters(in: range, with: string) as String
        } else if let pastedString = UIPasteboard.general.string, pastedString == string {
            // in case the textfield returns that something went wrong, we have to check the pasted text
            let pastedText = handlePastedString(replacementString: string)
            textField.text = pastedText
            newText = pastedText
        } else {
            newText = textField.text ?? ""
        }
        
        var additionalCondition = true
        let isErasing = string.isEmpty && range.length > 0
        let currentCaretPosition = isErasing ? range.location : range.location + string.count - range.length
        
        additionalCondition = handleIBANTextFieldChanges(withFutureText: newText, caretPosition: currentCaretPosition)
        return additionalCondition && shouldChangeCharacters
    }
    
    // MARK: - Handle methods
    
    /// Returns the string pasted filtered by characterSet and length (starting by rigth)
    ///
    /// - Parameters:
    ///   - textField: the IBANLisboaTextField
    ///   - string: the string pasted
    /// - Returns: the string filtered
    func handlePastedString(replacementString string: String) -> String {
        guard isValidPastedText(string) else {
            return ""
        }
        guard let length = self.length, let characterSet = characterSet else {
            return self.text ?? ""
        }
        let filteredString = string.filterValidCharacters(characterSet: characterSet)
        if filteredString.count > length {
            return filteredString.substring(filteredString.count - length) ?? self.field.text ?? ""
        }
        return self.text ?? ""
    }
    
    @discardableResult
    func handleIBANTextFieldChanges(withFutureText text: String, caretPosition: Int? = nil) -> Bool {
        guard let countryCode = bankingUtils?.countryCode, let length = self.length else { return true }
        if text.count == self.length {
            if let controlDigit = fixedControlDigit {
                self.leftLabel?.text = "\(countryCode)\(controlDigit)"
            } else {
                let checkDigit = bankingUtils?.calculateCheckDigit(bban: text) ?? ""
                self.leftLabel?.text = "\(countryCode)\(checkDigit.isEmpty ? "XX" : checkDigit)"
            }
            // workaround to fix caret position when full iban is pasted
            if caretPosition == 24, let newCaretPosition = self.field.position(from: self.field.endOfDocument, offset: 0) {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.field.selectedTextRange = self.field.textRange(from: newCaretPosition, to: newCaretPosition)
                }
            }
            return true

        } else {
            let controlDigit = fixedControlDigit ?? "XX"
            self.leftLabel?.text = "\(countryCode)\(controlDigit)"
            return text.count <= length
        }
    }
}
