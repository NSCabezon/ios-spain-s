import UI
import UIKit
import CoreFoundationLib
import IQKeyboardManagerSwift

public protocol OneIBANTextFieldDelegate: AnyObject {
    func didBeginEditing()
    func didChangeIBAN(_ text: String?)
    func didEndEditing()
}

public final class OneIBANTextField: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var backgroundLayer: UIView!
    @IBOutlet private weak var countryFlagContainerView: UIView!
    @IBOutlet private weak var countryFlagImageView: UIImageView!
    @IBOutlet private weak var countryCodeLabel: UILabel!
    @IBOutlet private weak var textField: ConfigurableActionsTextField!
    @IBOutlet private weak var closeContainer: UIView!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private weak var containerButton: UIButton!
    private weak var bankingUtils: BankingUtilsProtocol?
    private var status: OneStatus = .inactive
    public weak var delegate: OneIBANTextFieldDelegate?
    
    public var fieldValue: String? {
        didSet {
            self.updateFieldValue()
        }
    }

    private enum Constants {
        static let maxTextFieldLenght = 60
    }
    
    // MARK: - Public methods
    
    public init(viewModel: OneIBANTextFieldViewModel, _ bankingUtils: BankingUtilsProtocol) {
        super.init(frame: .zero)
        self.setup()
        self.set(viewModel: viewModel)
        self.setBankingUtils(bankingUtils)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    public func set(viewModel: OneIBANTextFieldViewModel) {
        if let style = viewModel.style {
            self.setup(status: style)
        }
        if let filledIban = viewModel.filledIban {
            self.placeholderLabel.isHidden = true
            let range = NSRange(location: 0, length: textField.text?.count ?? 0)
            _ = self.textField(self.textField, shouldChangeCharactersIn: range, replacementString: filledIban)
        }
        if let delegate = viewModel.delegate {
            self.delegate = delegate
        }
        if let pasteCompletion = viewModel.pasteCompletion {
            self.textField.pasteCompletion = pasteCompletion
        }
        self.setAccessibilitySuffix(viewModel.accessibilitySuffix ?? "")
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    public func setBankingUtils(_ bankingUtils: BankingUtilsProtocol) {
        self.bankingUtils = bankingUtils
        self.countryCodeLabel.text = bankingUtils.countryCode ?? ""
        self.countryCodeLabel.isHidden = countryCodeLabel.text?.isEmpty ?? true
        self.textField.keyboardType = bankingUtils.textInputAttributes.keyboardType
        self.setDoneKeyboardButton()
        self.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.updateTextFieldAccessibilityLabel()
    }
    
    public func setFlagImage(url: String) {
        _ = self.countryFlagImageView.setImage(url: url) { [weak self] image in
            if let image = image {
                self?.countryFlagImageView.image = image
                self?.countryFlagContainerView.isHidden = !(self?.status.showsFlag ?? true)
            } else {
                self?.countryFlagContainerView.isHidden = true
            }
        }
    }
    
    @IBAction func didTapOnTextField(_ sender: Any) {
        guard self.status != .disabled else { return }
        self.textField.becomeFirstResponder()
    }
    
    public func getIBAN() -> String? {
        let countryCode = self.countryCodeLabel.text ?? ""
        let iban = self.textField.text ?? ""
        return countryCode + iban
    }
    
    public func setInputText(_ text: String?) {
        self.textField.text = text
        self.placeholderLabel.isHidden = !(text ?? "").isEmpty
    }
    
    public func getCountryCode() -> String {
        return self.countryCodeLabel.text ?? ""
    }
    
    public func setIBAN(_ iban: String?) {
        self.textField.text = iban
    }
}

extension OneIBANTextField: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.setup(status: .focused)
        self.placeholderLabel.isHidden = true
        delegate?.didBeginEditing()
        self.closeContainer.isHidden = !shouldShowCloseButton
        self.containerButton.isHidden = true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let valueIsEmpty = self.fieldValue?.isEmpty ?? true
        self.setup(status: valueIsEmpty ? .inactive: .activated)
        self.closeContainer.isHidden = true
        self.containerButton.isHidden = false
        self.delegate?.didEndEditing()
        self.endEditing(true)
        guard valueIsEmpty else { return }
        self.placeholderLabel.isHidden = false
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let originalString = textField.text ?? ""
        let bridgedString = originalString as NSString
        let newString = String(string.unicodeScalars.filter { CharacterSet.iban.contains($0) })
        let replacingText = bridgedString.replacingCharacters(in: range, with: newString) as String
        guard let ibanRegEx = try? NSRegularExpression(pattern: "[a-zA-Z]{2}[0-9]."),
              let ibanWithLettersRegEx = try? NSRegularExpression(pattern: "[a-zA-Z]{2}[0-9a-zA-Z].")
        else { return false }
        if newString.match(regex: self.isCountryAlphanumeric ? ibanWithLettersRegEx : ibanRegEx) {
            self.handleIbanWithLetters(newString)
        } else if string.isEmpty && range.location > 0 {
            self.handleDeletion(range, originalString, replacingText, newString)
        } else if CharacterSet.numbers.isSuperset(of: CharacterSet(charactersIn: newString)) || self.isCountryAlphanumeric {
            self.handleNumber(range, originalString, replacingText, newString)
        }
        self.closeContainer.isHidden = !shouldShowCloseButton
        return false
    }
}

private extension OneIBANTextField {
    var isCountryAlphanumeric: Bool {
        return self.bankingUtils?.textInputAttributes.keyboardType != .numberPad
    }
    
    var isSepaCountry: Bool {
        return self.bankingUtils?.isSepaCountry ?? false
    }

    var shouldShowCloseButton: Bool {
        return self.fieldValue?.isEmpty == false && status == .focused
    }
    
    func setup() {
        self.backgroundColor = .clear
        self.backgroundLayer.backgroundColor = .oneSkyGray
        self.countryCodeLabel.font = .typography(fontName: .oneH100Regular)
        self.countryCodeLabel.textColor = .oneLisboaGray
        self.placeholderLabel.font = .typography(fontName: .oneH100Regular)
        self.placeholderLabel.textColor = .oneBrownishGray
        self.placeholderLabel.configureText(withKey: "sendMoney_label_iban")
        self.placeholderLabel.accessibilityIdentifier = "sendMoney_label_iban"
        self.textField.font = .typography(fontName: .oneH100Regular)
        self.textField.textColor = .oneLisboaGray
        self.textField.delegate = self
        self.closeImageView.image = Assets.image(named: "icnOneCloseOval")
        self.closeImageView.isUserInteractionEnabled = true
        self.closeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeTextField)))
        self.setAccessibility()
        self.setAccessibilityIdentifiers()
    }
    
    func setup(status: OneStatus) {
        self.status = status
        self.containerView.drawBorder(color: status.borderColor)
        self.containerView.setOneShadows(type: status.shadowStyle)
        self.countryCodeLabel.textColor = status.selectedInputLabelColor
        self.textField.textColor = status.selectedInputLabelColor
        self.countryFlagContainerView.isHidden = !status.showsFlag
        self.backgroundLayer.isHidden = self.countryFlagContainerView.isHidden
        self.containerView.backgroundColor = status.backgroundColor
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.fieldValue = textField.text
    }
    
    @objc func removeTextField() {
        self.fieldValue = ""
        self.closeContainer.isHidden = true
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.countryFlagImageView.accessibilityIdentifier = AccessibilityOneComponents.oneInputIBANIcn +
            ("_\(self.countryCodeLabel.text ?? "")") + (suffix ?? "")
        self.countryCodeLabel.accessibilityIdentifier = AccessibilityOneComponents.oneInputIBANPrefix
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.oneInputIBANTextField
        self.closeImageView.accessibilityIdentifier = AccessibilityOneComponents.oneInputIBANClear
    }
    
    func setAccessibility() {
        self.countryCodeLabel.isAccessibilityElement = false
        self.containerButton.isAccessibilityElement = false
        self.placeholderLabel.isAccessibilityElement = false
        self.closeImageView.isAccessibilityElement = true
        self.closeImageView.accessibilityLabel = localized("voiceover_deleteAllCharacters")
    }
    
    func setDoneKeyboardButton() {
        if UIAccessibility.isVoiceOverRunning {
            guard let toolbar = self.textField.setToolbarDoneButton(completion: {
                self.toolbarDoneTapButton()
            }) else { return }
            self.textField.inputAccessoryView = toolbar
        }
    }
    
    func updateTextFieldAccessibilityLabel() {
        self.textField.accessibilityLabel = "\(localized("voiceover_hint_enterIban")), \(self.countryCodeLabel.text ?? "")"
    }
    
    func toolbarDoneTapButton() {
        self.textFieldDidEndEditing(self.textField)
    }
}

// MARK: - Handle methods
private extension OneIBANTextField {
    func setFieldValue(with text: String) {
        guard text.count <= Constants.maxTextFieldLenght else { return }
        self.fieldValue = String(text)
    }

    func handleIbanWithLetters(_ string: String) {
        guard let regularExpression = try? NSRegularExpression(pattern: "[a-zA-Z]{2}") else { return }
        let results = string.matches(regex: regularExpression)
        guard let firstResult = results.first,
              let countryCode = self.bankingUtils?.countryCode,
              firstResult == countryCode
        else {
            guard self.isCountryAlphanumeric else { return }
            self.setFieldValue(with: string)
            self.fixCaret(to: string.count)
            return
        }
        let finalString = string.dropFirst(2)
        self.setFieldValue(with: String(finalString))
        self.fixCaret(to: string.count)
    }
    
    func handleDeletion(_ range: NSRange, _ originalString: String, _ replacingText: String, _ string: String) {
        var currentCaretPosition = range.location
        var replacingText = replacingText
        // If the selection has more than one element, don't try to remove extra characters
        if range.length <= 1, originalString[originalString.index(originalString.startIndex, offsetBy: currentCaretPosition)] == " " {
            currentCaretPosition -= 1
            let spaceRange = NSRange(location: currentCaretPosition, length: range.length)
            replacingText = (replacingText as NSString).replacingCharacters(in: spaceRange, with: string)
        }
        let finalString = replacingText.filter { !$0.isWhitespace }
        self.setFieldValue(with: finalString)
        self.fixCaret(to: currentCaretPosition)
    }
    
    func handleNumber(_ range: NSRange, _ originalString: String, _ replacingText: String, _ newString: String) {
        var currentCaretPosition = range.location
        let index = originalString.index(originalString.startIndex, offsetBy: currentCaretPosition)
        if index == originalString.endIndex || originalString[index] == " " {
            currentCaretPosition += 1
        }
        let finalString = replacingText.filter { !$0.isWhitespace }
        self.setFieldValue(with: finalString)
        self.fixCaret(to: currentCaretPosition + newString.count)
    }
    
    func fixCaret(to position: Int) {
        // When deleting, the caret loses the focus because of the behaviour of fieldValue's didSet. That's why this is needed.
        guard let newCaretPosition = self.textField.position(
                from: self.textField.beginningOfDocument,
                offset: position
        ) else { return }
        self.textField.selectedTextRange = self.textField.textRange(
            from: newCaretPosition,
            to: newCaretPosition
        )
    }
    
    func updateFieldValue() {
        guard let fieldValue = self.fieldValue,
              let countryCode = self.countryCodeLabel.text else {
            return
        }
        guard !fieldValue.isEmpty else {
            self.textField.text = ""
            self.delegate?.didChangeIBAN(nil)
            return
        }
        guard let controlDigits = fieldValue.substring(0, 2), !controlDigits.isEmpty,
              let accountNumber = fieldValue.substring(2, fieldValue.count), !accountNumber.isEmpty else {
            self.textField.text = fieldValue
            self.delegate?.didChangeIBAN(countryCode + fieldValue)
            return
        }
        let text: String = { [weak self] in
            guard let self = self,
                  self.isSepaCountry else { return controlDigits + accountNumber }
            let splits = accountNumber.split(byLength: 4)
            let text = controlDigits + " " + splits[1..<splits.count].reduce("\(splits[0])", {"\($0) \($1)"})
            return text
        }()
        self.textField.text = text
        self.placeholderLabel.isHidden = true
        self.delegate?.didChangeIBAN(countryCode + fieldValue)
    }
}

fileprivate extension OneStatus {
    var showsFlag: Bool {
        return self != .disabled
    }
    
    var borderColor: UIColor {
        switch self {
        case .inactive, .activated: return .oneBrownGray
        case .focused: return .oneDarkTurquoise
        case .disabled: return .oneLightGray40
        case .error: return .oneSantanderRed
        }
    }
    
    var shadowStyle: OneShadowsType {
        switch self {
        case .inactive, .activated, .focused, .error: return .oneShadowSmall
        case .disabled: return .none
        }
    }
    
    var selectedInputLabelColor: UIColor {
        switch self {
        case .activated, .focused, .error, .inactive: return .oneLisboaGray
        case .disabled: return .oneBrownGray
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .activated, .focused, .error, .inactive: return .oneWhite
        case .disabled: return .oneLightGray40
        }
    }
}
