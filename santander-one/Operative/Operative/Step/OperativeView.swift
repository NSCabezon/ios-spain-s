import UIKit
import UI
import CoreFoundationLib

/// Describes an OperativeView
public protocol OperativeView: LoadingViewPresentationCapable, DialogViewPresentationCapable, OldDialogViewPresentationCapable, OperativeStepViewProgressBarConfigurable {
    var associatedViewController: UIViewController { get }
    var operativePresenter: OperativeStepPresenterProtocol { get }
    var title: String? { get }
}

public extension OperativeView where Self: UIViewController {
    var associatedViewController: UIViewController {
        self
    }
}

public protocol OperativeStepViewProgressBarConfigurable: AnyObject {
    var progressBarBackgroundColor: UIColor { get }
}

extension OperativeView {
    public var associatedLoadingView: UIViewController {
        return associatedViewController
    }
}

extension OperativeView {
    public var associatedDialogView: UIViewController {
        return associatedViewController
    }
}

public extension OperativeView where Self: UIViewController {
    func operativeViewWillDisappear() {
        guard !(navigationController?.viewControllers.contains(self) ?? true) else { return }
        if let coordinator = self.transitionCoordinator {
            if !(navigationController?.viewControllers.last is OperativeView) {
                coordinator.animate(alongsideTransition: { _ in
                    self.operativePresenter.container?.progressBarAlpha(0.0)
                })
            }  
            coordinator.notifyWhenInteractionChanges { (context) in
                if context.initiallyInteractive && !context.isCancelled {
                    self.operativePresenter.container?.didSwipeBack()
                }
            }
        }
    }
    
    func restoreProgressBar() {
        self.operativePresenter.container?.bringProgressBarToTop()
    }
    
    var progressBarBackgroundColor: UIColor {
        return .skyGray
    }
}
