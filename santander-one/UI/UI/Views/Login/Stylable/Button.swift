import UIKit

public struct ButtonStylist: Stylist {
    public typealias T = UIButton
    let textColor: UIColor
    let font: UIFont
    let borderColor: UIColor?
    let borderWidth: CGFloat?
    let backgroundColor: UIColor?
    
    public init(textColor: UIColor, font: UIFont, borderColor: UIColor? = nil, borderWidth: CGFloat? = nil, backgroundColor: UIColor? = nil) {
        self.textColor = textColor
        self.font = font
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.backgroundColor = backgroundColor
    }
    
    public func performStyling(_ object: UIButton) {
        object.setTitleColor(textColor, for: .normal)
        object.titleLabel?.font = font
        if let borderColor = borderColor {
            object.layer.borderColor = borderColor.cgColor
        }
        if let borderWidth = borderWidth {
            object.layer.borderWidth = borderWidth
        }
        if let backgroundColor = backgroundColor {
            object.backgroundColor = backgroundColor
        }
    }
    
    public static var rememberedLogin: ButtonStylist {
        let size: CGFloat = Screen.isIphone4 ?  14.0 : 16.0
        let font = UIFont.santander(family: .lato, type: .semibold, size: size)
        return ButtonStylist(textColor: UIColor.Legacy.uiWhite, font: font, borderColor: nil, borderWidth: nil, backgroundColor: .clear)
    }
    
    public static var rememberedLoginPad: ButtonStylist {
        let font = UIFont.santander(family: .lato, type: .bold, size: 29.0)
        return ButtonStylist(textColor: UIColor.Legacy.uiWhite, font: font, borderColor: UIColor.Legacy.uiWhite, borderWidth: 2.0, backgroundColor: .clear)
        
    }
    
    public static var rememberedLoginOk: ButtonStylist {
        let font = UIFont.santander(family: .lato, type: .regular, size: 29)
        return ButtonStylist(textColor: UIColor.Legacy.uiWhite, font: font, borderColor: UIColor.Legacy.uiWhite, borderWidth: 2.0, backgroundColor: UIColor.Legacy.sanRed)
    }
    
    public static var genericSignatureAcceptButton: ButtonStylist {
        let font = UIFont.santander(family: .lato, type: .medium, size: 16)
        return ButtonStylist(textColor: UIColor.Legacy.uiWhite, font: font, borderColor: nil, borderWidth: nil, backgroundColor: .lisboaGray)
    }
}

extension UIButton: Stylable {
}
