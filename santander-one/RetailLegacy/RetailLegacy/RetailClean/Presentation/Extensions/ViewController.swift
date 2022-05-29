import UIKit

protocol ViewControllerProxy {
    var viewController: UIViewController { get }
}

extension UIViewController: ViewControllerProxy {
    var viewController: UIViewController {
        return self
    }
}

extension UIViewController {
    class func topViewController(from: UIViewController? = nil) -> UIViewController? {
        var viewController: UIViewController
        if from == nil {
            guard let keyWindow = UIApplication.shared.keyWindow else {
                return nil
            }
            guard let rootViewController = keyWindow.rootViewController else {
                return nil
            }
            viewController = rootViewController
        } else {
            viewController = from!
        }
        
        if let presented = viewController.presentedViewController {
            return topViewController(from: presented)
        }
        
        if !viewController.children.isEmpty {
            if let tabBarController = viewController as? UITabBarController,
                let selected = tabBarController.selectedViewController {
                    return topViewController(from: selected)
            } else if let baseMenuViewController = viewController as? BaseMenuViewController {
                return topViewController(from: baseMenuViewController.currentRootViewController)
            }
            return topViewController(from: viewController.children.last)
        }
        
        return viewController
    }
}

// MARK: Frame Util

extension UIViewController {
    var safeFrame: CGRect {
        let frame: CGRect
        if #available(iOS 11.0, *) {
            frame = CGRect(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top, width: view.bounds.width - view.safeAreaInsets.right, height: view.bounds.height - view.safeAreaInsets.bottom)
        } else {
            frame = CGRect(x: 0, y: topLayoutGuide.length, width: view.bounds.width, height: view.bounds.height - bottomLayoutGuide.length)
        }
        return frame
    }
}
