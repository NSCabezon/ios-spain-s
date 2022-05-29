import UIKit
import CoreFoundationLib

class CustomActivityViewController: UIActivityViewController, ForcedRotatable {
    func forcedOrientationForPresentation() -> UIInterfaceOrientation {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
        modalPresentationStyle = .formSheet
        completionWithItemsHandler = { [weak self] _, _, _, _  -> Void in
            self?.forceOrientationForPresentation()
        }
    }
}
