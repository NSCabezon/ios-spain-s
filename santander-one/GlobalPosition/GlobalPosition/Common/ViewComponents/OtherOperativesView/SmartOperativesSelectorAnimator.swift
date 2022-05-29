import UIKit
import UI

class SmartOperativesSelectorAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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
        
        guard let topButtonsContainerView = toView.viewWithTag(95) else { return }
        guard let topSuperview = toView.viewWithTag(98) else { return }
        guard let buttonsContainerView = toView.viewWithTag(97) else { return }
        guard let backgroundImageView = toView.viewWithTag(96) as? UIImageView else { return }
        topButtonsContainerView.alpha = 0
        topSuperview.alpha = 0
        buttonsContainerView.alpha = 1
        backgroundImageView.alpha = 1
        
        toView.layoutIfNeeded()
        
        guard let originalBackgroundImage = backgroundImageView.image, let cgImage = originalBackgroundImage.cgImage?.copy() else { return }
        
        let backgroundImage = UIImage(cgImage: cgImage,
                               scale: originalBackgroundImage.scale,
                               orientation: originalBackgroundImage.imageOrientation)
        
        // Custom background image
        let newBackgroundImageView = UIImageView(frame: CGRect(x: backgroundImageView.frame.minX, y: backgroundImageView.frame.maxY, width: backgroundImageView.frame.width, height: 0))
        newBackgroundImageView.image = backgroundImage
        container.insertSubview(newBackgroundImageView, aboveSubview: fromView)
        
        let renderer = UIGraphicsImageRenderer(bounds: buttonsContainerView.bounds)
        let actionsImage = renderer.image { rendererContext in
            buttonsContainerView.layer.render(in: rendererContext.cgContext)
        }
        toView.alpha = 0
        buttonsContainerView.alpha = 0
        backgroundImageView.alpha = 0
        
        // Custom options view
        let actionsImageView = UIImageView(frame: CGRect(x: buttonsContainerView.frame.minX, y: buttonsContainerView.frame.maxY, width: buttonsContainerView.frame.width, height: buttonsContainerView.frame.height))
        actionsImageView.image = actionsImage
        container.insertSubview(actionsImageView, aboveSubview: newBackgroundImageView)
        
        // Custom options bar
        let optionsBarImageView = UIImageView(frame: originFrame)
        optionsBarImageView.image = image
        container.insertSubview(optionsBarImageView, aboveSubview: actionsImageView)
        
        let blackCourtine = UIView(frame: topSuperview.frame)
        blackCourtine.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        blackCourtine.alpha = 0
        container.insertSubview(blackCourtine, aboveSubview: newBackgroundImageView)
        
        var realTopContainerFrame = topButtonsContainerView.convert(topButtonsContainerView.frame, to: nil)
        realTopContainerFrame.origin = CGPoint(x: realTopContainerFrame.minX - 8, y: realTopContainerFrame.minY)
        
        UIView.animate(withDuration: duration, animations: {
            optionsBarImageView.frame = realTopContainerFrame
            newBackgroundImageView.frame = backgroundImageView.frame
            actionsImageView.frame = buttonsContainerView.frame
            blackCourtine.alpha = 1
        }, completion: { _ in
            toView.alpha = 1
            topButtonsContainerView.alpha = 1
            topSuperview.alpha = 1
            buttonsContainerView.alpha = 1
            backgroundImageView.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            newBackgroundImageView.removeFromSuperview()
            actionsImageView.removeFromSuperview()
            optionsBarImageView.removeFromSuperview()
            blackCourtine.removeFromSuperview()
        })
    }
    
    func dismissingAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        container.backgroundColor = UIColor.clear
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        container.insertSubview(toView, belowSubview: fromView)
        
        guard let originView = fromView.viewWithTag(95) else { return }
        originView.alpha = 0
        guard let destinyView = toView.viewWithTag(199) else { return }
        destinyView.alpha = 0
        
        var realTopContainerFrame = originView.convert(originView.frame, to: nil)
        realTopContainerFrame.origin = CGPoint(x: realTopContainerFrame.minX - 8, y: realTopContainerFrame.minY)
        
        let transitionImageView = UIImageView(frame: realTopContainerFrame)
        transitionImageView.image = image
        container.addSubview(transitionImageView)
    
        let bottomFrame = CGRect(x: fromView.frame.minX, y: fromView.frame.maxY, width: fromView.frame.width, height: fromView.frame.height)
                
        UIView.animate(withDuration: duration, animations: {
            transitionImageView.frame = self.originFrame
            fromView.frame = bottomFrame
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
