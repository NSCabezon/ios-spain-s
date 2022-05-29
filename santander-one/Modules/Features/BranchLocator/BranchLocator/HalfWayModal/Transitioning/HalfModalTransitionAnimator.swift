import UIKit

class HalfModalTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	
	var type: HalfModalTransitionAnimatorType
	
	init(type: HalfModalTransitionAnimatorType) {
		self.type = type
	}
	
	@objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//		let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
		let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
		
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
			fromVC!.view.frame.origin.y = 800
		}, completion: { _ -> Void in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.4
	}
}

internal enum HalfModalTransitionAnimatorType {
	case present
	case dismiss
}
