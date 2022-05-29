import UIKit
import Foundation

public extension UIViewController {
    static var topVisibleViewController: UIViewController? {
        if var tc = UIApplication.shared.keyWindow?.rootViewController {
            while let vc = tc.presentedViewController {
                tc = vc
            }
            return tc
        }
        return nil
    }
    
    var topVisibleViewController: UIViewController {
        if let tc = UIViewController.topVisibleViewController {
            return tc
        }
        return self
    }

    static func initFromStoryboard<T>(name: String, identifier: String) -> T {
        guard let vc = UIStoryboard(name: name, bundle: nil)
            .instantiateViewController(withIdentifier: identifier) as? T else {
                fatalError("\(identifier) could not be loaded from \(name) as \(T.self)")
        }
        
        return vc
    }
}
