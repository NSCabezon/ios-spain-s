import UIKit

private typealias Style = (border: UIColor, background: UIColor)

//@IBDesignable
class WhiteButton: ColorButton {
    private let enabledStyle = Style(border: .sanRed, background: .uiWhite)
    private let disabledStyle = Style(border: .uiBlack, background: .lisboaGray)
    
    override var isEnabled: Bool {
        didSet {
            colourForState()
        }
    }
    
    override func configure() {
        super.configure()
        tintColor = .sanRed
        setTitleColor(.sanRed, for: .normal)
        setTitleColor(.uiBlack, for: .disabled)
        layer.borderWidth = 1.0
        layer.masksToBounds = false
        isEnabled = true
    }
    
    internal func colourForState() {
        let style = isEnabled ? enabledStyle : disabledStyle
        layer.borderColor = style.border.cgColor
        backgroundColor = style.background
    }
    
    func configureHighlighted(font: UIFont) {
        super.configure()
        let styleButton = ButtonStylist(textColor: .sanRed, font: font, borderColor: .sanRed, borderWidth: 1, backgroundColor: .uiWhite)
        let styleButtonSelected = ButtonStylist(textColor: .uiWhite, font: font, borderColor: .sanRed, borderWidth: 1, backgroundColor: .sanRed)
        applyHighlightedStylist(normal: styleButton, selected: styleButtonSelected)
    }
}
