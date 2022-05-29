import UIKit

extension UIFont {
    class func font(name: String, size: CGFloat) -> UIFont {
        return UIFont(name: name, size: size) ?? fontDoesNotExists(name: name, size: size)
    }
    
    class private func fontDoesNotExists(name: String, size: CGFloat) -> UIFont {
        RetailLogger.e(String(describing: type(of: self)), "Cannot load \(name) font")
        return systemFont(ofSize: size)
    }
}
