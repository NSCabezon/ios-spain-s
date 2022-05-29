import CoreFoundationLib

extension BaseMenuViewController {
    
    override open var shouldAutorotate: Bool {
        guard let visibleVC = UIApplication.topViewController(controller: currentRootViewController) else { return false }
        return visibleVC is Rotatable
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        guard let visibleVC = UIApplication.topViewController(controller: currentRootViewController) else { return .portrait }
        if let rotatable = visibleVC as? Rotatable {
            return rotatable.preferredOrientationForPresentation()
        }
        return visibleVC.preferredInterfaceOrientationForPresentation
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let visibleVC = UIApplication.topViewController(controller: currentRootViewController) else { return .portrait }
        if let rotatable = visibleVC as? Rotatable {
            return rotatable.supportedOrientations()
        }
        if #available(iOS 10, *) {
            return visibleVC.supportedInterfaceOrientations
        } else {
            return .portrait
        }

    }
}

extension UIApplication {    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        if let menuViewController = controller as? BaseMenuViewController {
            return topViewController(controller: menuViewController.currentRootViewController)
        }
        return controller
    }
}
