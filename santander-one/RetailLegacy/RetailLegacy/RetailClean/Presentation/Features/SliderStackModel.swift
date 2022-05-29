class SliderStackModel: StackItem<SliderStackView>, InputIdentificable {
    
    let inputIdentifier: String
    var dataEntered: String? {
        return String(currentValue)
    }
    private let placeholder: LocalizedStylableText?
    private let type: KeyboardTextFieldResponderOrder?
    private let minimumText: LocalizedStylableText?
    private let maximumText: LocalizedStylableText?
    private(set) var currentValue: Float
    var didChangeSliderValue: ((_ value: Float?) -> Void)?
    var setSliderValue: ((Float) -> Void)?
    
    init(inputIdentifier: String, placeholder: LocalizedStylableText?, currentValue: Float, minimumText: LocalizedStylableText?, maximumText: LocalizedStylableText?, insets: Insets = Insets(left: 10, right: 10, top: 0, bottom: 40), maxLength: Int? = nil, nextType: KeyboardTextFieldResponderOrder? = nil) {
        self.placeholder = placeholder
        self.inputIdentifier = inputIdentifier
        self.type = nextType
        self.minimumText = minimumText
        self.maximumText = maximumText
        self.currentValue = currentValue
        super.init(insets: insets)
    }
    
    override func bind(view: SliderStackView) {
        view.setMaximumText(maximumText)
        view.setMinimumText(minimumText)
        view.setNewValue(currentValue)
        view.didChangeValue = { [weak self] value in
            self?.currentValue = value
            self?.didChangeSliderValue?(value)
        }
        setSliderValue = view.setNewValue
        view.setAccessibilityIdentifiers(identifier: inputIdentifier)
    }
    
}
