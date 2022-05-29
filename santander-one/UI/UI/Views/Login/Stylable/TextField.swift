import UIKit

public struct TextFieldStylist: Stylist {
    public typealias T = UITextField
    public let textColor: UIColor
    public let font: UIFont
    public let textAlignment: NSTextAlignment
    
    public init(textColor: UIColor, font: UIFont, textAlignment: NSTextAlignment) {
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
    }
    
    public func performStyling(_ object: UITextField) {
        performStyling(textField: object)
    }
    
    public func performStyling(_ object: ResponsiveTextField) {
        performStyling(textField: object as UITextField)
    }
    
    private func performStyling(textField: UITextField) {
        textField.textColor = textColor
        textField.font = font
        textField.textAlignment = textAlignment
    }
    
    public static var login: TextFieldStylist {
        let font = UIFont.santander(family: .lato, type: .regular, size: 18)
        return TextFieldStylist(textColor: UIColor.Legacy.uiBlack, font: font, textAlignment: .left)
    }
}

extension UITextField: Stylable {}

extension ResponsiveTextField {
    public func applyStyle(_ stylist: TextFieldStylist) {
        stylist.performStyling(self)
    }
}
