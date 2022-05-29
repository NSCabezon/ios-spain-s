class AmountInputStackModel: StackItem<AmountInputStackView>, InputIdentificable {
    private let titleText: LocalizedStylableText?
    private let placeholderText: LocalizedStylableText?
    var dataEntered: String?
    let inputIdentifier: String
    var textFormatMode: FormattedTextField.FormatMode?
    var inputValueDidChange: (() -> Void)?
    let style: TextFieldStylist?
    
    init(inputIdentifier: String, titleText: LocalizedStylableText? = nil, placeholderText: LocalizedStylableText? = nil, textFormatMode: FormattedTextField.FormatMode? = .defaultCurrency(4, 0), style: TextFieldStylist? = nil, insets: Insets = Insets(left: 10, right: 10, top: 22, bottom: 0)) {
        self.titleText = titleText
        self.placeholderText = placeholderText
        self.inputIdentifier = inputIdentifier
        self.textFormatMode = textFormatMode
        self.style = style
        super.init(insets: insets)
    }
    
    override func bind(view: AmountInputStackView) {
        view.textFormatMode = textFormatMode
        view.style = style
        view.setTitle(titleText)
        view.dataEntered = dataEntered
        view.newTextFieldValue = { [weak self] newValue in
            self?.dataEntered = newValue
            self?.inputValueDidChange?()
        }
        guard let placeholderText = placeholderText else { return }
        view.formattedAmountTextField.setOnPlaceholder(localizedStylableText: placeholderText)
    }
    
    func setCurrentValue(_ value: String) {
        dataEntered = value
        inputValueDidChange?()
    }
}
