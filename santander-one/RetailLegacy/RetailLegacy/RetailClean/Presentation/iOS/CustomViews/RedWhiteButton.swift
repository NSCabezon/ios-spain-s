import UIKit

private typealias Style = (border: UIColor, background: UIColor)

@IBDesignable
class RedWhiteButton: ColorButton {
    
    func configureHighlighted(font: UIFont, isRed: Bool = true) {
        super.configure()

        let styleButton = ButtonStylist(textColor: .sanRed, font: font, borderColor: .sanRed, borderWidth: 1, backgroundColor: .uiWhite)
        let styleRedButton = ButtonStylist(textColor: .uiWhite, font: font, borderColor: .sanRed, borderWidth: 1, backgroundColor: .sanRed)

        let styleButtonSelected = ButtonStylist(textColor: .sanRed, font: font, borderColor: .sanRed, borderWidth: 1, backgroundColor: .sky)
        let styleRedButtonSelected = ButtonStylist(textColor: .uiWhite, font: font, borderColor: .sanRed, borderWidth: 1, backgroundColor: .bostonRed)
        
        applyHighlightedStylist(normal: isRed ? styleRedButton : styleButton, selected: isRed ? styleRedButtonSelected : styleButtonSelected)
    }
           
}
