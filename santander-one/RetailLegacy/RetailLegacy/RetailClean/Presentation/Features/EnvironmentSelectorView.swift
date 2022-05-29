import UIKit
import CoreFoundationLib
import UI

class EnvironmentSelectorView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectorControl: ResponsiveTextField!
    @IBOutlet weak var separator: UIView!
    
    class func create() -> EnvironmentSelectorView {
        guard let view = Bundle.module?.loadNibNamed("EnvironmentSelectorView", owner: nil, options: nil)?.first as? EnvironmentSelectorView else {
            fatalError()
        }
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func configure() {
        titleLabel.font = .latoRegular(size: 17.0)
        titleLabel.textColor = .sanRed
        self.titleLabel.accessibilityIdentifier = AccessibilityEnvironmentSelector.lblEnvironment.rawValue
        selectorControl.font = .latoRegular(size: 18.0)
        selectorControl.textColor = .sanGreyDark
        selectorControl.text = ""
        selectorControl.reponderOrder = KeyboardTextFieldResponderOrder.none
        selectorControl.accessibilityIdentifier = AccessibilityEnvironmentSelector.txtEnvironment.rawValue
        separator.backgroundColor = .uiWhite
    }

    func disable() {
        selectorControl.isEnabled = false
    }
}
