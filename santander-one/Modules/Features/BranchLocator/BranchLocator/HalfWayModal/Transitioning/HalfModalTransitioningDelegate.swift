import UIKit

class HalfModalTransitioningDelegate: NSObject {
    weak var viewController: UIViewController?
    var presentingViewController: UIViewController?
    var presentationController: HalfModalPresentationController?
    var interactiveDismiss = false
    
    init(viewController: UIViewController, presentingViewController: UIViewController) {
        self.viewController = viewController
        self.presentingViewController = presentingViewController
        super.init()
    }
}
extension HalfModalTransitioningDelegate: UIViewControllerTransitioningDelegate {
    
    func isOpen() -> Bool? {
        guard let presentationController = presentationController else {
            return nil
        }
        
        switch presentationController.state {
        case .adjustedOnce:
            return false
        case .normal:
            return true
        }
    }
    
    func handleOpenOrClose() {
        if let presentationController = presentationController {
            switch presentationController.state {
            case .adjustedOnce:
                presentationController.changeScale(to: .normal)
            case .normal:
                presentationController.changeScale(to: .adjustedOnce)
                //  ANALYTICS REMOVED
//                BLAnalyticsHandler.track(event: .detailView, screenName: BlEvent.detailView.rawValue, isScreen: false)
            }
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HalfModalTransitionAnimator(type: .dismiss)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        presentationController = HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewController? {
        if interactiveDismiss {
            return self.presentingViewController
        }
        return nil
    }  
}



