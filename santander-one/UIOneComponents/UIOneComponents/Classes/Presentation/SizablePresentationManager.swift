import UIKit

final class SizablePresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    private var presentation: SizablePresentationType = .half()
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SizablePresentationController(presentedViewController: presented, presenting: presenting, presentation: self.presentation)
    }
    
    func setPresentation(_ presentation: SizablePresentationType) {
        self.presentation = presentation
    }
}
