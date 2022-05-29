//
//  OtherOperativesAnimator.swift
//  GlobalPosition
//
//  Created by alvola on 08/01/2020.
//

import UIKit
import UI

class OtherOperativesAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: TimeInterval = 0.5
    var isPresenting: Bool
    var originFrame: CGRect
    var image: UIImage?
    
    override init() {
        self.isPresenting = true
        self.originFrame = CGRect.zero
        self.image = nil
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresenting ? presentingAnimation(using: transitionContext) : dismissingAnimation(using: transitionContext)
    }
    
    func presentingAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        container.backgroundColor = UIColor.clear
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        container.addSubview(fromView)
        container.addSubview(toView)
        
        guard let destinyView = toView.viewWithTag(99) else { return }
        destinyView.alpha = 0
        
        guard let destinyCourtine = toView.viewWithTag(98) else { return }
        destinyCourtine.alpha = 0
        
        toView.alpha = 0
        toView.layoutIfNeeded()
        
        let transitionImageView = UIImageView(frame: originFrame)
        transitionImageView.image = image
        container.addSubview(transitionImageView)
        
        let blueCourtine = UIView(frame: CGRect(origin: originFrame.origin, size: CGSize(width: originFrame.width, height: 0)))
        blueCourtine.backgroundColor = UIColor.skyGray
        container.insertSubview(blueCourtine, belowSubview: transitionImageView)
        
        let grayCourtine = UIView(frame: blueCourtine.frame)
        grayCourtine.frame.origin.y += 1.5
        grayCourtine.backgroundColor = UIColor.mediumSkyGray
        container.insertSubview(grayCourtine, belowSubview: blueCourtine)
        
        UIView.animate(withDuration: duration, animations: {
            transitionImageView.frame = destinyView.frame
            blueCourtine.frame = fromView.frame
            grayCourtine.frame = fromView.frame
            grayCourtine.frame.origin.x += 1.5
        }, completion: { _ in
            toView.alpha = 1
            UIView.animate(withDuration: self.duration / 2.0, animations: {
                blueCourtine.frame = destinyCourtine.frame
                grayCourtine.frame = destinyCourtine.frame
                grayCourtine.frame.origin.y += 1.5
            }, completion: { _ in
                destinyView.alpha = 1
                destinyCourtine.alpha = 1
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                transitionImageView.removeFromSuperview()
                blueCourtine.removeFromSuperview()
                grayCourtine.removeFromSuperview()
            })
        })
    }
    
    func dismissingAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        container.backgroundColor = UIColor.clear
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        container.insertSubview(toView, belowSubview: fromView)
        
        guard let originView = fromView.viewWithTag(99) else { return }
        originView.alpha = 0
        guard let destinyView = toView.viewWithTag(199) else { return }
        destinyView.alpha = 0
        
        let transitionImageView = UIImageView(frame: originView.frame)
        transitionImageView.image = image
        container.addSubview(transitionImageView)
                
        UIView.animate(withDuration: duration, animations: {
            transitionImageView.frame = self.originFrame
            fromView.alpha = 0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            transitionImageView.removeFromSuperview()
            destinyView.alpha = 1
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}
