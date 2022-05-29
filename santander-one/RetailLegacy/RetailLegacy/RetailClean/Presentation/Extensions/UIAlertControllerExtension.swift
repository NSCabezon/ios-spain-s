import UIKit

extension UIAlertController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if #available(iOS 10, *) {
            return super.supportedInterfaceOrientations
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    open override var shouldAutorotate: Bool {
        if #available(iOS 10, *) {
            return super.shouldAutorotate
        } else {
            return false
        }
    }
}
