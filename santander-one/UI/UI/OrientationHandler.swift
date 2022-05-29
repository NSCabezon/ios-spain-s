import UIKit

public protocol OrientationHandler: AnyObject {
    var orientation: UIInterfaceOrientationMask { get set }
    var oldOrientation: UIInterfaceOrientationMask? { get set }
}

public extension OrientationHandler {
    func applyOrientation(_ orientation: UIInterfaceOrientationMask) {
        oldOrientation = self.orientation
        self.orientation = orientation
    }
    
    func restoreOrientation() {
        guard let oldOrientation = oldOrientation else { return }
        orientation = oldOrientation
        self.oldOrientation = nil
    }
}
