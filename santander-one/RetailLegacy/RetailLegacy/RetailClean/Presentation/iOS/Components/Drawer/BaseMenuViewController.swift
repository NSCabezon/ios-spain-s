import UIKit
import UI
import CoreFoundationLib
import CoreDomain

typealias RootableViewController = UIViewController & RootMenuController

protocol BaseMenuViewControllerDelegate: class {
    func blackViewTouched()
    /// Tells when side menu is closed with swipe gesture
    func didSwipeSideMenu(_ isClosed: Bool)
}

protocol MenuEventCapable {
    func didShowSideMenu(_ isVisible: Bool)
}

public class BaseMenuViewController: UIViewController, BaseMenuController {
    private var legacyResolver: DependenciesResolver
    private let menuWidthPercentage: CGFloat = 0.915
    lazy var sideMenuNotifier: SideMenuNotifier = SideMenuNotifier()
    private lazy var rootView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var sideMenu: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lisboaBlue
        view.addGestureRecognizer(panGesture)
        return view
    }()
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.uiBlack.withAlphaComponent(0.65)
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(shadowTapGesture)
        return view
    }()
    private lazy var rightEdgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePanGesture.edges = .right
        edgePanGesture.delegate = self
        return edgePanGesture
    }()
    private lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        return panGesture
    }()
    private lazy var shadowTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(blackViewTapHandler(_:)))
        tap.require(toFail: panGesture)
        return tap
    }()
    private var leftSpace: NSLayoutConstraint!
    public var isSideMenuVisible: Bool {
        guard leftSpace != nil else { return false }
        return leftSpace.constant < 0
    }
    private var sideMenuOpenWidth: CGFloat {
        return -sideMenu.bounds.width
    }

    private(set) public var currentRootViewController: (UIViewController & CoreFoundationLib.RootMenuController)?
    private(set) public var currentSideMenuViewController: UIViewController?

    var isSideMenuAvailable: Bool {
        guard isVisibleCoachmark == false,
            isDialogPresented == false,
            isNotSideMenuProtocol == false else { return false }
        return currentRootViewController?.isSideMenuAvailable ?? false
    }
    
    var isVisibleCoachmark: Bool {
        return currentRootViewController?.presentedViewController is CoachmarksViewController
    }
    
    var isDialogPresented: Bool {
        return currentRootViewController?.presentedViewController is DialogViewController
    }
    
    var isNotSideMenuProtocol: Bool {
        return currentRootViewController?.presentedViewController is NotSideMenuProtocol
    }
    private let isPrivateSideMenuEnabled: Bool
    
    public init(legacyResolver: DependenciesResolver) {
        let localAppConfig = legacyResolver.resolve(for: LocalAppConfig.self)
        self.isPrivateSideMenuEnabled = localAppConfig.privateMenu
        self.legacyResolver = legacyResolver
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(rootView)
        view.addSubview(sideMenu)
        
        setupSideMenuConstraints()
        setupRootViewConstraints()
        self.setupAccessibilityIds()
        
        view.addGestureRecognizer(rightEdgePanGesture)
        
        setRightEdgePanGesture(enabled: true)
    }
    
    // MARK: - Public
    
    func setRoot(viewController: RootableViewController?) {
        closeSideMenu()
        if let currentViewController = currentRootViewController {
            remove(currentViewController)
        }
        guard let nextViewController = viewController else {
            return
        }
        setViewController(nextViewController, to: .root)
    }
    
    func setSideMenu(viewController: UIViewController?) {
        if let currentViewController = currentSideMenuViewController {
            remove(currentViewController)
        }
        guard let nextViewController = viewController else {
            return
        }
        setViewController(nextViewController, to: .sideMenu)
    }
    
    public func toggleSideMenu() {
        guard isPrivateSideMenuEnabled else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
            return
        }
        if !isSideMenuVisible {
            insertBlackView()
            if let navigationController = currentRootViewController as? UINavigationController,
                let firsViewController = navigationController.viewControllers.last as? HighlightedMenuProtocol {
                    privateMenuEventsRepository.willShowMenu(highlightedOption: firsViewController.getOption())
            }
            view.layoutIfNeeded()
        } else {
            privateMenuEventsRepository.didHideMenu()
        }
        leftSpace.constant = isSideMenuVisible ? 0 : sideMenuOpenWidth
        updateToFinalPosition()
    }
    
    public func closeSideMenu() {
        guard isSideMenuVisible == true else { return }
        leftSpace.constant = 0
        updateToFinalPosition()
    }
    
    func setRightEdgePanGesture(enabled: Bool) {
        rightEdgePanGesture.isEnabled = enabled && isPrivateSideMenuEnabled
    }
    
    // MARK: - Events
    
    @objc func handleEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        guard isSideMenuAvailable == true else {
            return
        }
        switch sender.state {
        case .began:
            insertBlackView()
        case .changed:
            let xTranslation = sender.translation(in: sender.view).x
            if xTranslation >= sideMenuOpenWidth {
                leftSpace.constant = xTranslation
                let percentageDone = xTranslation / sideMenuOpenWidth
                if shadowView.superview == nil && percentageDone > 0 {
                    insertBlackView()
                }
                shadowView.alpha = percentageDone
            }
        case .cancelled, .ended:
            updateToFinalPosition()
        case .failed, .possible: //Ignoring
            break
        @unknown default:
            break
        }
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            break
        case .changed:
            let xTranslation = sender.translation(in: view).x
            sender.setTranslation(.zero, in: view)
            if leftSpace.constant + xTranslation < 0 && 
                leftSpace.constant + xTranslation > sideMenuOpenWidth {
                leftSpace.constant += xTranslation
                let percentage = leftSpace.constant / sideMenuOpenWidth
                if shadowView.superview == nil && percentage > 0 {
                    insertBlackView()
                }
                shadowView.alpha = percentage
            }
        case .cancelled, .ended:
            updateToFinalPosition()
        case .failed, .possible: //Ignoring
            break
        @unknown default:
            break
        }
    }
    
    @objc func blackViewTapHandler(_ sender: UITapGestureRecognizer) {
        sideMenuNotifier.blackViewTouched()
        toggleSideMenu()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        
        let visibleView = isSideMenuVisible ? currentSideMenuViewController : currentRootViewController
        
        if let controller = visibleView as? NavigationController {
            if #available(iOS 13.0, *) {
                return controller.topViewController?.preferredStatusBarStyle ?? .darkContent
            } else {
                return controller.topViewController?.preferredStatusBarStyle ?? .default
            }
        } else {
            if #available(iOS 13.0, *) {
                return self.children.last?.preferredStatusBarStyle ?? .darkContent
            } else {
                return self.children.last?.preferredStatusBarStyle ?? .default
            }
        }
    }
}

extension BaseMenuViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return isSideMenuAvailable
    }
}

private extension BaseMenuViewController {
    
    // MARK: - Types
    enum ViewPosition {
        case root
        case sideMenu
    }
    
    // MARK: - Setup
    func setupSideMenuConstraints() {
        if #available(iOS 11.0, *) {
            sideMenu.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        } else {
            sideMenu.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        sideMenu.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        sideMenu.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: menuWidthPercentage).isActive = true
        leftSpace = sideMenu.leftAnchor.constraint(equalTo: view.rightAnchor)
        leftSpace.isActive = true
    }
    
    func setupAnchors(from childView: UIView, to superView: UIView) {
        childView.topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        childView.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        childView.leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
        childView.rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
    }
    
    func setupRootViewConstraints() {
        setupAnchors(from: rootView, to: view)
    }
    
    func setupAccessibilityIds() {
        self.navigationController?.navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityOthers.btnMenu.rawValue
    }
    
    // MARK: - Helpers
    func insertBlackView() {
        view.insertSubview(shadowView, belowSubview: sideMenu)
        setupAnchors(from: shadowView, to: view)
    }
    
    func updateToFinalPosition() {
        let isHiding: Bool
        if leftSpace.constant < sideMenuOpenWidth / 2 {
            leftSpace.constant = sideMenuOpenWidth
            isHiding = false
        } else {
            leftSpace.constant = 0
            isHiding = true
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.shadowView.alpha = isHiding ? 0.0 : 1.0
        }, completion: { _ in
            self.sideMenuNotifier.didSwipeSideMenu(isClosed: isHiding)
            if isHiding {
                self.shadowView.removeFromSuperview()
            }
            self.notifyCurrentMenu(isHiding: isHiding)
        })
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func viewFor(position: ViewPosition) -> UIView {
        switch position {
        case .root:
            return rootView
        case .sideMenu:
            return sideMenu
        }
    }
    
    private func setViewController(_ viewController: UIViewController, to position: ViewPosition) {
        guard let newView = viewController.view else {
            return
        }
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(viewController)
        let destinationView = viewFor(position: position)
        destinationView.addSubview(newView)
        newView.frame = destinationView.frame
        setupAnchors(from: newView, to: destinationView)
        viewController.didMove(toParent: self)
        switch position {
        case .root:
            currentRootViewController = viewController as? RootableViewController
        case .sideMenu:
            currentSideMenuViewController = viewController
        }
    }
    
    func remove(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    private func notifyCurrentMenu(isHiding: Bool) {
        let viewController = (currentSideMenuViewController as? UINavigationController)?.viewControllers.last
        viewController?.view.accessibilityElementsHidden = isHiding
        (viewController as? MenuEventCapable)?.didShowSideMenu(!isHiding)
        if !isHiding {
            privateMenuEventsRepository.didShowMenu()
        }
    }
}

extension BaseMenuViewController {
    var privateMenuEventsRepository: PrivateMenuEventsRepository {
        let retailLegacyExternalDependencies = self.legacyResolver.resolve(for: RetailLegacyExternalDependenciesResolver.self)
        return retailLegacyExternalDependencies.resolve()
    }
}
