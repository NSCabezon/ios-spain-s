import UIKit

public enum SizablePresentationType {
    case half(isPan: Bool = false, bottomVisible: Bool = false, tapOutsideDismiss: Bool = true)
    case top(isPan: Bool = false, bottomVisible: Bool = false, tapOutsideDismiss: Bool = true)
    case custom(height: CGFloat? = nil, isPan: Bool = false, bottomVisible: Bool = false, tapOutsideDismiss: Bool = true)
    
    func isPan() -> Bool {
        switch self {
        case .half(let isPan, _, _):
            return isPan
        case .top(let isPan, _, _):
            return isPan
        case .custom(_, let isPan, _, _):
            return isPan
        }
    }
    
    func isBottomVisible() -> Bool {
        switch self {
        case .half(_, let isBottomVisible, _):
            return isBottomVisible
        case .top(_, let isBottomVisible, _):
            return isBottomVisible
        case .custom(_, _, let isBottomVisible, _):
            return isBottomVisible
        }
    }
    
    func shouldDismissOnTap() -> Bool {
        switch self {
        case .half(_, _, let tapOutsideDismiss):
            return tapOutsideDismiss
        case .top(_, _, let tapOutsideDismiss):
            return tapOutsideDismiss
        case .custom(_, _, _, let tapOutsideDismiss):
            return tapOutsideDismiss
        }
    }
    
    init(type: SizablePresentationType, tapOutsideDismiss: Bool) {
        switch type {
        case .half(let isPan, let bottomVisible, _):
            self = .half(isPan: isPan, bottomVisible: bottomVisible, tapOutsideDismiss: tapOutsideDismiss)
        case .top(let isPan, let bottomVisible, _):
            self = .top(isPan: isPan, bottomVisible: bottomVisible, tapOutsideDismiss: tapOutsideDismiss)
        case .custom(let height, let isPan, let bottomVisible, _):
            self  = .custom(height: height, isPan: isPan, bottomVisible: bottomVisible, tapOutsideDismiss: tapOutsideDismiss)
        }
    }
}

final class SizablePresentationController: UIPresentationController {
    private let backgroundView = UIView()
    private var presentation: SizablePresentationType?
    private var direction: CGFloat = 0
    private let topHeight: CGFloat = 80.0
    private var topSafeAreaHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return self.containerView?.safeAreaInsets.top ?? 40.0
        } else {
            return 40.0
        }
    }
    private var bottomSafeAreaHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return self.containerView?.safeAreaInsets.bottom ?? 0.0
        } else {
            return 0.0
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            return self.getViewSize()
        }
    }
    
    override init(presentedViewController: UIViewController,
                  presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.setupBackgroundView()
        self.addRoundedView()
    }
    
    convenience init(presentedViewController: UIViewController,
                     presenting presentingViewController: UIViewController?,
                     presentation: SizablePresentationType) {
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.presentation = presentation
        self.addCloseTapGesture()
        self.addPanGesture(presentedViewController)
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
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.backgroundView.removeFromSuperview()
        }
    }
}

private extension SizablePresentationController {
    func setupBackgroundView() {
        self.backgroundView.backgroundColor = .lisboaGray
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.alpha = 0
    }
    
    func addBackgroundView() {
        guard let containerView = containerView else { return }
        containerView.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.backgroundView.alpha = 0.6
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 0.6
        })
    }
    
    func removeBackgroundView() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.presentingViewController.view.transform = .identity
            self.backgroundView.removeFromSuperview()
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.backgroundView.removeFromSuperview()
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
    
    func addCloseTapGesture() {
        guard let shouldDismiss = self.presentation?.shouldDismissOnTap(), shouldDismiss else { return }
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(backgroundViewWasTapped(gesture:)))
        backgroundView.addGestureRecognizer(closeTap)
        backgroundView.isUserInteractionEnabled = true
    }
    
    @objc func backgroundViewWasTapped(gesture: UIGestureRecognizer) {
        if gesture.state == .ended {
            self.presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func addPanGesture(_ viewController: UIViewController) {
        guard let isPan = self.presentation?.isPan(), isPan == true else { return }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(pan:)))
        viewController.view.addGestureRecognizer(panGesture)
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        let endPoint = pan.translation(in: pan.view?.superview)
        switch pan.state {
        case .began:
            break
        case .changed:
            let velocity = pan.velocity(in: pan.view?.superview)
            presentedView?.frame.origin.y = max(endPoint.y + self.getViewSize().origin.y, self.getViewHeight())
            direction = velocity.y
        case .ended:
            if direction > 0 {
                presentedViewController.dismiss(animated: true, completion: nil)
            } else {
                presentedView?.frame = self.frameOfPresentedViewInContainerView
            }
        default:
            break
        }
    }
    
    func getViewSize() -> CGRect {
        guard let customView = self.containerView else { return .zero }
        let y = getViewHeight()
        return CGRect(x: 0, y: y, width: customView.bounds.width, height: customView.bounds.height - y)
    }
    
    func getViewHeight() -> CGFloat {
        guard let customView = self.containerView else { return .zero }
        let y: CGFloat
        switch self.presentation {
        case .top:
            y =  self.topHeight
        case .half:
            y = customView.bounds.height * 0.5
        case .custom(let height, _, _, _):
            guard let height = height else { return .zero }
            y = max(customView.bounds.height - bottomSafeAreaHeight - height - self.topSafeAreaHeight - getStatusBarHeight(), getStatusBarHeight())
        case .none:
            y = 0.0
        }
        return y
    }
    
    func getStatusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
}
