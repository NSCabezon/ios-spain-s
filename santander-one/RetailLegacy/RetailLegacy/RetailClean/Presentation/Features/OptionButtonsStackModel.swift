import UIKit

typealias OptionType = (value: String, valueToDisplay: String)

class OptionButtonsStackModel: StackItem<OptionButtonsStackView> {
    
    private let values: [ValueOptionType]
    var onSelection: ((String) -> Void)?
    private var changeVisibility: ((Bool) -> Void)?
    private var isVisible = false
    var selectedValue: String? {
        didSet {
            values.forEach {
                $0.setHighlightedIfMatches(value: selectedValue)
            }
        }
    }
    
    init(values: [OptionType], isVisible: Bool = true, insets: Insets = Insets(left: 11, right: 10, top: 15, bottom: 4)) {
        self.values = values.map {
            let value = $0.value
            return ValueOptionType(value: value, displayableValue: $0.valueToDisplay) }
        self.isVisible = isVisible
        super.init(insets: insets)
        for value in self.values {
            value.action = { [weak self] in
                self?.selectedValue = self?.selectedValue != value.value ? value.value : nil
                self?.onSelection?(value.value)
            }
        }
    }
    
    func setVisibility(_ isVisible: Bool) {
        self.isVisible = isVisible
        changeVisibility?(isVisible)
    }
    
    func clear() {
        selectedValue = nil
    }
    
    override func bind(view: OptionButtonsStackView) {
        view.addValues(values)
        changeVisibility = view.setVisibility
        view.setVisibility(isVisible)
    }
    
}
