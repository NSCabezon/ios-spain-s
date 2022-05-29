import Foundation

class RadioWithoutOptionsData {
    var isSelected: Bool {
        didSet {
            didUpdateSelection?(isSelected)
        }
    }
    let title: LocalizedStylableText
    var didUpdateSelection: ((Bool) -> Void)?
    var type: String
    let accessibilityIdentifier: String
    
    init(isSelected: Bool, title: LocalizedStylableText, type: String, accessibilityIdentifier: String) {
        self.isSelected = isSelected
        self.title = title
        self.type = type
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

class RadioNotExpandableStackModel: StackItem<RadioExpandableStackView>, InputIdentificable {
    var dataEntered: String? {
        return selectedOption?.type
    }
    let inputIdentifier: String
    var radioOptionsData: [RadioWithoutOptionsData]
    
    private var selectedOption: RadioWithoutOptionsData? {
        return radioOptionsData.first(where: {$0.isSelected})
    }
    init(inputIdentifier: String, options: [RadioWithoutOptionsData], insets: Insets = Insets(left: 10, right: 10, top: 0, bottom: 40)) {
        self.inputIdentifier = inputIdentifier
        self.radioOptionsData = options
        super.init(insets: insets)
    }
    
    override func bind(view: RadioExpandableStackView) {
        for (index, option) in radioOptionsData.enumerated() {
            let v = RadioButtonCustomView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.setTitle(option.title.text)
            v.setAccessibilityIdentifiers(identifier: option.accessibilityIdentifier)
            view.addView(v)
            v.setSelected(option.isSelected)
            option.didUpdateSelection = { [weak v] newValue in
                v?.setSelected(newValue)
            }
            v.didSelect = { [weak self] newValue in
                self?.unselectAllOptions(excluding: option)
            }
            if index == radioOptionsData.count {
                v.isSeparatorVisible = false
            }
        }
    }
    
    private func unselectAllOptions(excluding option: RadioWithoutOptionsData) {
        for o in radioOptionsData {
            o.isSelected = o === option
        }
    }
}
