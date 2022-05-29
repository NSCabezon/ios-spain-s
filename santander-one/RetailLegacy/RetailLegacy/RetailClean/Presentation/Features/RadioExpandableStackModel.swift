import Foundation
import CoreFoundationLib

class RadioOptionData {
    var isSelected: Bool {
        didSet {
            didUpdateSelection?(isSelected)
        }
    }
    let placeholder: LocalizedStylableText?
    let title: LocalizedStylableText
    let options: [ValueOptionType]
    let identifier: String?
    var enteredText: String?
    var didUpdateSelection: ((Bool) -> Void)?
    var encodeDataEntered: (String?) -> String?
    var dataEntered: String? {
        return encodeDataEntered(enteredText)
    }
    
    init(isSelected: Bool, placeholder: LocalizedStylableText?, title: LocalizedStylableText, identifier: String? = nil, options: [ValueOptionType], encodeData: @escaping (String?) -> String?) {
        self.isSelected = isSelected
        self.placeholder = placeholder
        self.title = title
        self.identifier = identifier
        self.options = options
        self.encodeDataEntered = encodeData
    }
}

class RadioExpandableStackModel: StackItem<RadioExpandableStackView>, InputIdentificable {
    
    let inputIdentifier: String
    var dataEntered: String? {
       return selectedOption?.dataEntered
    }
    var radioOptionsData: [RadioOptionData]
    private let type: KeyboardTextFieldResponderOrder
    private var selectedOption: RadioOptionData? {
        return radioOptionsData.first(where: {$0.isSelected})
    }
    init(inputIdentifier: String, options: [RadioOptionData], insets: Insets = Insets(left: 10, right: 10, top: 0, bottom: 40), nextType: KeyboardTextFieldResponderOrder = .none) {
        self.inputIdentifier = inputIdentifier
        self.type = nextType
        self.radioOptionsData = options
        super.init(insets: insets)
    }
    
    override func bind(view: RadioExpandableStackView) {
        for (index, option) in radioOptionsData.enumerated() {
            let v = RadioButtonCustomView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.setTitle(option.title.text)
            let optionsView = AmountOptionsView()
            optionsView.options = option.options
            optionsView.translatesAutoresizingMaskIntoConstraints = false
            optionsView.enteredTextDidChange = { newValue in
                option.enteredText = newValue
            }
            optionsView.setPlaceholderText(option.placeholder)
            if let identifier = option.identifier {
                optionsView.setAccessibilityIdentifers(identifier: identifier)
                v.setAccessibilityIdentifiers(identifier: identifier)
            }
            v.setCustomView(optionsView)
            view.addView(v)
            v.setSelected(option.isSelected)
            option.didUpdateSelection = { [weak v] newValue in
                v?.setSelected(newValue)
                option.enteredText = nil
            }
            optionsView.setKeyboardTextFieldOrder(type)
            v.didSelect = { [weak self] newValue in
                self?.unselectAllOptions(excluding: option)
            }
            if index == radioOptionsData.count {
                v.isSeparatorVisible = false
            }
        }
    }
    
    private func unselectAllOptions(excluding option: RadioOptionData) {
        for o in radioOptionsData {
            o.isSelected = o === option
        }
    }
}
