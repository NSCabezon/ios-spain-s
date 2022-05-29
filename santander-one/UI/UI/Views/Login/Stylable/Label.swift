import UIKit

public struct LabelStylist: Stylist {
    let textColor: UIColor
    let font: UIFont
    let textAlignment: NSTextAlignment
    
    public init(textColor: UIColor, font: UIFont, textAlignment: NSTextAlignment = .left) {
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
    }
    
    public func performStyling(_ object: UILabel) {
        object.textColor = textColor
        object.font = font
        object.textAlignment = textAlignment
    }
    
    public static var pgDefaultHeaderLabel: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanGreyDark, font: .santander(family: .lato, type: .bold, size: 14))
    }
    
    public static var pgDefaultHeaderValue: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanGreyDark, font: .santander(family: .lato, type: .bold, size: 23.0))
    }
    
    public static var pgBasketTitle: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanGreyDark, font: .santander(family: .lato, type: .bold, size: 15))
    }
    
    public static var pgBasketAmountLabel: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanGreyMedium, font: .santander(family: .lato, type: .regular, size: 13))
    }
    
    public static var pgBasketAmountValue: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanGreyDark, font: .santander(family: .lato, type: .bold, size: 21))
    }
    
    public static var pgProductName: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanGreyDark, font: .santander(family: .lato, type: .regular, size: 15))
    }
    
    public static var pgProductSubName: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanGreyMedium, font: .santander(family: .lato, type: .regular, size: 14))
    }
    
    public static var pgProductAmount: LabelStylist {
        return LabelStylist(textColor: .sanGreyDark, font: .santander(family: .lato, type: .bold, size: 18))
    }
    
    public static var rememberedLoginUserName: LabelStylist {
        let size: CGFloat = Screen.isIphone4 ?  18.0 : 20.0
        return LabelStylist(textColor: UIColor.Legacy.uiWhite, font: .santander(family: .lato, type: .semibold, size: size),
                            textAlignment: .center)
    }
    
    public static var rememberedLoginMagicComponent: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.uiWhite, font: .santander(family: .lato, type: .regular, size: 40))
    }
    
    public static var dateDay: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanRed, font: .santander(family: .lato, type: .regular, size: 18), textAlignment: .center)
    }
    
    public static var dateMonth: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanRed, font: .santander(family: .lato, type: .regular, size: 11.0), textAlignment: .center)
    }
    
    public static var productHomeMenuOptions: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanGreyDark, font: .santander(family: .lato, type: .bold, size: 12), textAlignment: .center)
    }
    
    public static var productHomeOptionsTitleSection: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanRed, font: .santander(family: .lato, type: .bold, size: 18.0), textAlignment: .left)
    }
    
    public static var rightTransactionPriceLabel: LabelStylist {
        return LabelStylist(textColor: .sanGreyDark, font: .santander(family: .lato, type: .bold, size: 22.0), textAlignment: .right)
    }
    
    public static var conceptTitleTransaction: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanGreyDark, font: .santander(family: .lato, type: .regular, size: 15), textAlignment: .left)
    }
    
    public static var offerWhiteButton: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.uiWhite, font: .santander(family: .lato, type: .bold, size: 14), textAlignment: .center)
    }
    
    public static var offerRedButton: LabelStylist {
        return LabelStylist(textColor: UIColor.Legacy.sanRed, font: .santander(family: .lato, type: .bold, size: 14), textAlignment: .center)
    }
}

extension UILabel: Stylable {
}
