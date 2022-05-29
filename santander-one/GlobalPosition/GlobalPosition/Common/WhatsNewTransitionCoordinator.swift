//
//  WhatsNewTransitionCoordinator.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 30/06/2020.
//

import UI
import CoreFoundationLib

public protocol WhatsNewBubbleTransitionable: AnyObject {
    var bubbleTransitionCoordinator: WhatsNewTransitionCoordinator { get }
    var bubble: BubbleWhatsNew { get }
}

public final class WhatsNewTransitionCoordinator: NSObject, UIViewControllerTransitioningDelegate {
    private let transition = CircularTransition()

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let navigationController = source as? UINavigationController,
            let viewController = navigationController.viewControllers.first as? WhatsNewBubbleTransitionable else {
                return nil
        }
        transition.transitionMode = .present
        let globalPoint = viewController.bubble.superview?.convert(viewController.bubble.center, to: nil)
        transition.startingPoint = globalPoint ?? viewController.bubble.center
        transition.circleColor = .iceBlue
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = CGPoint.zero
        transition.circleColor = .iceBlue
        return transition
    }
}
