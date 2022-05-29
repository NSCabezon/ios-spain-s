import UIKit

@IBDesignable
class RedButton: ColorButton {
    private let enabledColor: UIColor = .sanRed
    private let disabledColor: UIColor = .lisboaGray
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? enabledColor : disabledColor
        }
    }
    
    override func configure() {
        super.configure()
        tintColor = .uiWhite
        setTitleColor(.uiWhite, for: .normal)
        setTitleColor(.lightGray, for: .disabled)
        isEnabled = true
    }
    
    func configureHighlighted(font: UIFont) {
        super.configure()
        let styleButton = ButtonStylist(textColor: .uiWhite, font: font, borderColor: .sanRed, borderWidth: 1, backgroundColor: .sanRed)
        let styleButtonSelected = ButtonStylist(textColor: .sanRed, font: font, borderColor: .sanRed, borderWidth: 1, backgroundColor: .uiWhite)
        applyHighlightedStylist(normal: styleButton, selected: styleButtonSelected)
    }
}

class StyledButton: ColorButton {
    var action: (() -> Void)?
    
    func setStyles(normal: ButtonStylist, selected: ButtonStylist) {
        applyHighlightedStylist(normal: normal, selected: selected)
    }
    
}
