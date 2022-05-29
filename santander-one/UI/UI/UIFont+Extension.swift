import UIKit

extension UIFont {
    class func font(name: String, size: CGFloat) -> UIFont {
        return UIFont(name: name, size: size) ?? fontDoesNotExists(name: name, size: size)
    }
    
    class private func fontDoesNotExists(name: String, size: CGFloat) -> UIFont {
        return systemFont(ofSize: size)
    }
}

public extension UIFont {
    static func scaledFont(with font: UIFont, maximumPointSize: CGFloat? = nil) -> UIFont {
        if #available(iOS 11.0, *) {
            guard let maximumPointSize = maximumPointSize else {
                return UIFontMetrics.default.scaledFont(for: font)
            }
            return UIFontMetrics.default.scaledFont(for: font, maximumPointSize: maximumPointSize)
        } else {
            return font
        }
    }
}
