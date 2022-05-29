import UIKit

enum ModalScaleState {
    case adjustedOnce
    case normal
}

class HalfModalPresentationController: UIPresentationController {
    var isMaximized: Bool = false 
    
    var panGestureRecognizer: UIPanGestureRecognizer
    var direction: CGFloat = 0
    var state: ModalScaleState = .normal
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.panGestureRecognizer = UIPanGestureRecognizer()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        let endPoint = pan.translation(in: pan.view?.superview)
        switch pan.state {
        case .began:
            break
        case .changed:
            let velocity = pan.velocity(in: pan.view?.superview)
            let posY = pan.translation(in: pan.view?.superview).y
            switch state {
            case .normal:
                presentedView?.frame.origin.y = posY
            case .adjustedOnce:
                presentedView?.frame.origin.y = endPoint.y
            }
            direction = velocity.y
        case .ended:
            if state == .adjustedOnce && endPoint.y < 0 {
                changeScale(to: .adjustedOnce)
                return
            } else {
                if direction <= 0 {
                    changeScale(to: .adjustedOnce)
                    //  ANALYTICS REMOVED
//                    BLAnalyticsHandler.track(event: .detailView, screenName: BlEvent.detailView.rawValue, isScreen: true)
                    
                } else {
                    if state == .adjustedOnce {
                        changeScale(to: .normal)
                    } else {
                        presentedViewController.dismiss(animated: true, completion: nil)
                    }
                }
            }
        default:
            break
        }
    }
    
    func changeScale(to state: ModalScaleState) {
        if let presentedView = presentedView,
            let containerView = containerView,
            let poiDetailVC = self.presentedViewController as? POIDetailViewController {
            
            let containerViewFrame = self.presentingViewController.view.frame
            let viewHeightAndSearchBarContainerY = poiDetailVC.presenter?.mapViewHeightAndSearchBarContainerY
            
            let mapViewControllerHeight = viewHeightAndSearchBarContainerY?.viewHeight ?? 0
            
            var height = viewHeightAndSearchBarContainerY?.searchBarContainerY ?? 80
            
            //Fixes the height difference that may be caused by a view frame height change in the MapViewController
            let differenceBetweenViews = containerViewFrame.height - mapViewControllerHeight
            
            height += differenceBetweenViews
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { () -> Void in
                presentedView.frame = containerViewFrame
                let containerFrame = containerViewFrame
                
                poiDetailVC.configureUI(for: state == .adjustedOnce)
                
                var safeAreaBottomInset: CGFloat = 0
                var top: CGFloat = 0
                
                if #available(iOS 11.0, *) {
                    safeAreaBottomInset = self.presentingViewController.view.safeAreaInsets.bottom
                }
                
                if #available(iOS 11.0, *) {
                    top = self.presentingViewController.view.safeAreaInsets.top
                }
                
                
                
                let halfFrame = CGRect(x: 0,
                                       y: containerViewFrame.height - poiDetailVC.topContentView.bounds.size.height - safeAreaBottomInset,
                                       width: containerView.frame.width,
                                       height: containerFrame.height)
                
                let fullFrame = CGRect(x: 0,
                                       y: height + top ,
                                       width: containerView.frame.width,
                                       height: containerViewFrame.size.height - (height))
                
                let frame = state == .adjustedOnce ? fullFrame : halfFrame
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.containerView?.frame = frame
                    self.containerView?.layoutIfNeeded()
                })
                
                if let navController = self.presentedViewController as? UINavigationController {
                    self.isMaximized = true
                    
                    navController.setNeedsStatusBarAppearanceUpdate()
                    
                    // Force the navigation bar to update its size
                    navController.isNavigationBarHidden = true
                    navController.isNavigationBarHidden = false
                }
            }, completion: { _ in
                self.state = state
            })
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let rect = CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height)
        return rect
    }
    
    override func presentationTransitionWillBegin() {
        if let containerView = self.containerView,
            let coordinator = presentingViewController.transitionCoordinator,
            let poiDetailVC = self.presentedViewController as? POIDetailViewController {
            
            containerView.frame.size.height = poiDetailVC.topContentView.frame.height
            
            var topMargin: CGFloat = 64
            if #available(iOS 11.0, *) {
                topMargin += presentingViewController.view.safeAreaInsets.top
            }
            let height: CGFloat = presentingViewController.view.frame.height - topMargin
            
            presentedViewController.view.frame = CGRect(x: 0,
                                                        y: 0,
                                                        width: presentingViewController.view.frame.width,
                                                        height: height)
            
            
            var safeAreaBottomInset: CGFloat = 0
            
            if #available(iOS 11.0, *) {
                safeAreaBottomInset = presentingViewController.view.safeAreaInsets.bottom
            }
            
            let yPos = presentingViewController.view.frame.size.height - poiDetailVC.topContentView.frame.height - safeAreaBottomInset
            
            containerView.frame = CGRect(x: 0,
                                         y: presentingViewController.view.frame.height,
                                         width: presentingViewController.view.frame.width,
                                         height: presentingViewController.view.frame.height)
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: { () -> Void in
                containerView.frame.origin.y = yPos
            })
            
            coordinator.animate(alongsideTransition: { _ -> Void in
                containerView.frame.origin.y = self.presentingViewController.view.frame.size.height - poiDetailVC.topContentView.frame.height - safeAreaBottomInset
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            
            coordinator.animate(alongsideTransition: { _ -> Void in
                self.presentingViewController.view.transform = CGAffineTransform.identity
            }, completion: nil)
            
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            isMaximized = false
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
}

protocol HalfModalPresentable { }

extension HalfModalPresentable where Self: UIViewController {
    func maximizeToFullScreen() {
        if let presetation = navigationController?.presentationController as? HalfModalPresentationController {
            presetation.changeScale(to: .adjustedOnce)
        }
    }
}

extension HalfModalPresentable where Self: UINavigationController {
    func isHalfModalMaximized() -> Bool {
        if let presentationController = presentationController as? HalfModalPresentationController {
            return presentationController.isMaximized
        }
        
        return false
    }
}
