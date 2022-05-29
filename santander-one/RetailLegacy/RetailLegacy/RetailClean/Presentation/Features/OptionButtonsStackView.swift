import UIKit

class OptionButtonsStackView: StackItemView {
    
    @IBOutlet weak var optionButtonsStack: OptionsStackView!
    
    func addValues(_ values: [ValueOptionType]) {
        optionButtonsStack.addValues(values)
    }
    
    func setVisibility(_ isVisible: Bool) {
        isHidden = !isVisible
    }
    
}

protocol VisibilityMutable {
    var isHidden: Bool { get set }
}
