import UIKit
import CoreFoundationLib

extension UIFont {
    public static func latoLight(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .light , size: size)
    }
    
    public static func latoRegular(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .regular , size: size)
    }
    
    public static func latoBold(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .bold , size: size)
    }
    
    public static func latoSemibold(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .semibold , size: size)
    }
    
    public static func latoMedium(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .medium , size: size)
    }
    
    public static func latoHeavy(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .heavy , size: size)
    }
    
    public static func latoLightItalic(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .lightItalic , size: size)
    }

    public static func latoItalic(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .italic , size: size)
    }
    
    public static func latoBoldItalic(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .boldItalic , size: size)
    }
    
    public static func halterRegular(size: CGFloat) -> UIFont {
        return font(name: "Halter", size: size)
    }
    
    public static func handOfSean(size: CGFloat) -> UIFont {
        return font(name: "HandOfSeanDemo", size: size)
    }
    
    public static func santanderHeadlineBold(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .headline, type: .bold , size: size)
    }
    
    public static func santanderHeadlineRegular(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .headline, type: .regular , size: size)
    }
    
    public static func santanderTextBold(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .text, type: .bold , size: size)
    }
    
    public static func santanderTextLight(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .text, type: .light , size: size)
    }
    
    public static func santanderTextRegular(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .text, type: .regular , size: size)
    }
}
