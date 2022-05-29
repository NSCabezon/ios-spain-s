import UIKit
import CoreFoundationLib

public extension UINavigationController {
    func blockingPushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        guard self.view.isUserInteractionEnabled else { return }
        self.view.isUserInteractionEnabled = false
        self.pushViewController(viewController, animated: animated) { [weak self] in
            self?.view.isUserInteractionEnabled = true
            completion?()
        }
    }
}
