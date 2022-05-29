import CoreFoundationLib

class IBANTextFieldStackModel: StackItem<IBANTextFieldStackView>, InputIdentificable, InputEditableIdentificable {
    let inputIdentifier: String
    var dataEntered: String?
    let placeholder: LocalizedStylableText?
    let country: SepaCountryInfo
    let bankingUtils: BankingUtilsProtocol?
    private var setTextFieldValue: ((String) -> Void)?
    private var initialText: String?

    init(inputIdentifier: String, placeholder: LocalizedStylableText?, country: SepaCountryInfo, bankingUtils: BankingUtilsProtocol, initialText: String? = nil, insets: Insets = Insets(left: 10, right: 10, top: 0, bottom: 8)) {
        self.placeholder = placeholder
        self.inputIdentifier = inputIdentifier
        self.country = country
        self.initialText = initialText
        self.bankingUtils = bankingUtils
        super.init(insets: insets)
    }
    
    override func bind(view: IBANTextFieldStackView) {
        view.bankingUtils = bankingUtils
        view.newTextFieldValue = { [weak self] value in
            self?.dataEntered = value
        }
        view.styledPlaceholder = placeholder
        view.info = IBANTextFieldInfo(country: country, length: country.bbanLength)
        if let initialText = initialText {
            view.ibanTextField.copyText(text: initialText)
            dataEntered = initialText
        }
        setTextFieldValue = view.setTextFieldValue
        if let text = dataEntered {
            view.ibanTextField.copyText(text: text)
            dataEntered = text.filter { !$0.isWhitespace }
        }
    }
    
    func setCurrentValue(_ value: String) {
        setTextFieldValue?(value)
    }
}
