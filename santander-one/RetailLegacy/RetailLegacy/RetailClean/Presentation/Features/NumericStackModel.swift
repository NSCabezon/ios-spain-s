class NumericStackModel: StackItem<NumericTextFieldStackView>, InputIdentificable {
    
    let inputIdentifier: String
    private(set) var dataEntered: String?
    private let placeholder: LocalizedStylableText?
    private let type: KeyboardTextFieldResponderOrder?
    private let numericMode: FormattedTextField.FormatMode
    private var setTextFieldValue: ((String?) -> Void)?
    var valueDidChange: ((_ value: String?) -> Void)?
    
    init(inputIdentifier: String, placeholder: LocalizedStylableText?, currentValue: String, numericMode: FormattedTextField.FormatMode = .currency(12, 2, "EUR"), insets: Insets = Insets(left: 10, right: 10, top: 8, bottom: 8), nextType: KeyboardTextFieldResponderOrder? = nil) {
        self.placeholder = placeholder
        self.inputIdentifier = inputIdentifier
        self.type = nextType
        self.dataEntered = currentValue
        self.numericMode = numericMode
        super.init(insets: insets)
    }
    
    func setCurrentValue(_ value: String) {
        dataEntered = value
        setTextFieldValue?(value)
    }
    
    override func bind(view: NumericTextFieldStackView) {
        view.setAccessibilityIdentifiers(identifier: inputIdentifier)
        view.setNumericMode(numericMode)
        view.styledPlaceholder = placeholder
        view.newTextFieldValue = { [weak self] value in
            self?.dataEntered = value
            self?.valueDidChange?(value)
        }
        setTextFieldValue = view.setTextFieldValue
        setTextFieldValue?(dataEntered)
        if let type = type {
            view.textField.reponderOrder = type
        }
    }
}
