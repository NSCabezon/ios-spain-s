import UIKit

final class HalfSizePresentationController: UIPresentationController {
    var backgroundView: UIView?

    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let customView = containerView else { return CGRect.zero }
            let yPoint = customView.bounds.height/2
            return CGRect(x: 0, y: yPoint, width: customView.bounds.width, height: customView.bounds.height - yPoint)
        }
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.setupBackgroundView()
        self.addRoundedView()
        self.addGestures()
    }

    override func presentationTransitionWillBegin() {
        self.addBackgroundView()
    }

    override func dismissalTransitionWillBegin() {
        self.removeBackgroundView()
    }

    override func containerViewWillLayoutSubviews() {
      presentedView?.frame = frameOfPresentedViewInContainerView
    }

}

private extension HalfSizePresentationController {
    func setupBackgroundView() {
        self.backgroundView = UIView()
        self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.backgroundView?.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView?.alpha = 0
    }

    func addBackgroundView() {
        guard let containerView = containerView, let backgroundView = backgroundView else { return }
        containerView.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        guard let coordinator = presentedViewController.transitionCoordinator else {
            backgroundView.alpha = 1.0
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.backgroundView?.alpha = 1.0
        })
    }

    func removeBackgroundView() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.backgroundView?.alpha = 0.0
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.backgroundView?.alpha = 0.0
        })
    }
    func addRoundedView() {
        self.presentedViewController.view.layer.cornerRadius = 10
        self.presentedViewController.view.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            self.presentedViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            self.presentedViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        }
    }

    func addGestures() {
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(backgroundViewWasTapped(gesture:)))
        backgroundView?.addGestureRecognizer(closeTap)
        backgroundView?.isUserInteractionEnabled = true
    }

    @objc func backgroundViewWasTapped(gesture: UIGestureRecognizer) {
        if gesture.state == .ended {
            self.presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
}
