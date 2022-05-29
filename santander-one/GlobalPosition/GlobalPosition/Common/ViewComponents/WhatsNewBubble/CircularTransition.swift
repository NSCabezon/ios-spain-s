//
//  CircularTransition.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 29/06/2020.
//

import UIKit
import UI

class CircularTransition: NSObject {
    // MARK: Global properties for CircularTransition
    var circle = UIView()
    var startingPoint = CGPoint.zero {
        didSet {
            circle.center = startingPoint
        }
    }
    var point: CGPoint {
        return circle.center
    }
    var circleColor = UIColor.white
    var duration = 0.9
    var transitionMode: CircularTransitionMode = .present
    let maxScreenHeight: CGFloat = 2435
    let defaultMargins: CGFloat = 0
    let updatedMargins: CGFloat = 30
    
    enum CircularTransitionMode: Int {
        case present, dismiss, pop
    }
}

private extension CircularTransition {
    // MARK: Methods used in UIViewControllerAnimatedTransitioning methods
    func frameForCircle(withViewCenter viewCenter: CGPoint, size: CGSize, startPoint: CGPoint) -> CGRect {
        let xLength = fmax(startPoint.x, size.width - startPoint.x)
        let yLength = fmax(startPoint.y, size.height - startPoint.y)
        let offestVector = sqrt(xLength * xLength + yLength * yLength) * 2
        let size = CGSize(width: offestVector, height: offestVector)
        return CGRect(origin: CGPoint.zero, size: size)
    }
    
    func isSmallDevice() -> Bool {
        return Screen.isScreenSizeBiggerThanIphone10XS()
    }
    
    func configurePresentedView(with presentedView: UIView, containerView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        let viewSize = presentedView.frame.size
        var viewCenter = self.viewCentered(with: presentedView)
        if Screen.isIphone8Plus {
            viewCenter.y += 20
        }
        self.circle = UIView()
        self.circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
        self.circle.layer.cornerRadius = circle.frame.size.height / 2
        self.circle.center = startingPoint
        self.circle.backgroundColor = circleColor
        self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        containerView.addSubview(circle)
        presentedView.center = startingPoint
        presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        presentedView.alpha = 0
        presentedView.backgroundColor = .clear
        containerView.addSubview(presentedView)
        self.animatePresentedView(with: presentedView, viewCenter: viewCenter, transitionContext: transitionContext)
    }
    
    func viewCentered(with presentedView: UIView) -> CGPoint {
        let isSmallDevice = self.isSmallDevice()
        let marginsIfNeeded: CGFloat = isSmallDevice ? updatedMargins : defaultMargins
        return CGPoint(x: presentedView.center.x - marginsIfNeeded, y: presentedView.center.y + marginsIfNeeded)
    }
    
    func animatePresentedView(with presentedView: UIView, viewCenter: CGPoint, transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: duration, animations: {
            self.circle.transform = CGAffineTransform.identity
            presentedView.transform = CGAffineTransform.identity
            presentedView.alpha = 1
            presentedView.center = viewCenter
            }, completion: { (success: Bool) in
                transitionContext.completeTransition(success)
        })
    }
    
    func configureReturningView(with returningView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        let viewCenter = returningView.center
        let viewSize = returningView.frame.size
        self.circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
        self.circle.layer.cornerRadius = circle.frame.size.height / 2
        self.circle.center = startingPoint
        returningView.center = viewCenter
        returningView.removeFromSuperview()
        self.circle.removeFromSuperview()
        transitionContext.completeTransition(true)
    }
}

extension CircularTransition: UIViewControllerAnimatedTransitioning {
    // MARK: Configure Transition
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        switch transitionMode {
        case .present:
            guard let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
            self.configurePresentedView(with: presentedView, containerView: containerView, transitionContext: transitionContext)
        default:
            let transitionModeKey = (transitionMode == .pop) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
            guard let returningView = transitionContext.view(forKey: transitionModeKey) else { return }
            self.configureReturningView(with: returningView, transitionContext: transitionContext)
        }
    }
}
