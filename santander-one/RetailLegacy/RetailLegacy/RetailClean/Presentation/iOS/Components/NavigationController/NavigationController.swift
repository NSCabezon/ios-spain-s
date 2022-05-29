import UI
import CoreFoundationLib

typealias ProgressBarInfo = (isVisible: Bool, backgroundColor: UIColor?)

protocol NavigationStackSemaphore: class {
    func allowStackChanges()
}

class NavigationController: UINavigationController {
    private var shouldWaitUntilStackChanged: Bool = false
    private var progressBarConstraint: NSLayoutConstraint?
    private weak var progressBar: NavigatorProgressBar?
    private let navigationDelegatesHandler = NavigationControllerDelegate()
    
    var isVisibleCoachmark: Bool {
        return presentedViewController is CoachmarksViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationDelegatesHandler.stackSemaphore = self
        self.delegate = navigationDelegatesHandler
        interactivePopGestureRecognizer?.delegate = self
        setup()
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: {
            MiniPlayerView.bringToFront()
            completion?()
        })
    }
    
    private func setup() {
        let appearance = UIBarButtonItem.appearance()
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.santanderRed], for: [.normal, .highlighted])
        let backImage = applyInsets(UIEdgeInsets(top: 2.5, left: 9.5, bottom: 0, right: 0), to: Assets.image(named: "icnReturnRed"))
        navigationBar.backIndicatorImage = backImage
        navigationBar.backItem?.leftBarButtonItem?.accessibilityIdentifier = "icnReturnRed"
        navigationBar.backItem?.leftBarButtonItem?.accessibilityLabel = localized("siri_voiceover_back")
        navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.santanderRed, .font: UIFont.latoRegular(size: 20)]
        setupProgressBar()
    }
    
    func applyInsets(_ insets: UIEdgeInsets, to image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: image.size.width + insets.left + insets.right,
                   height: image.size.height + insets.top + insets.bottom),
            false,
            image.scale)

        let origin = CGPoint(x: insets.left, y: insets.top)
        image.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageWithInsets
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        guard !isVisibleCoachmark else { return }
        super.setViewControllers(viewControllers, animated: animated)
        self.shouldWaitUntilStackChanged = false
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        guard !shouldWaitUntilStackChanged else { return nil }
        shouldWaitUntilStackChanged = true
        let controller = super.popViewController(animated: animated)
        if controller == nil {
            shouldWaitUntilStackChanged = false
        }
        return controller
    }
    
    func setProgress(_ progress: Progress?) {
        progressBar?.setProgress(progress)
    }
    
    private func setupProgressBar() {
        let progressBar = createNavigationProgressBar()
        self.progressBar = progressBar
        progressBar.isHidden = true
        progressBar.heightAnchor.constraint(equalToConstant: Constants.progressBarHeight).isActive = true
        view.insertSubview(progressBar, belowSubview: navigationBar)
        self.progressBarConstraint = progressBar.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Constants.progressBarHeight)
        self.progressBarConstraint?.isActive = true
        progressBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        progressBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        progressBar.backgroundColor = .clear
    }
    
    override var isNavigationBarHidden: Bool {
        didSet {
            updateProgressBarStatusForNavigationBarHidden(isNavigationBarHidden)
        }
    }
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        updateProgressBarStatusForNavigationBarHidden(hidden)
    }
    
    private func updateProgressBarStatusForNavigationBarHidden(_ hidden: Bool) {
        setTopConstraintToNavigationBar(!hidden)
        setProgressBarVisible(isProgressBarVisible)
    }
    
    private func setTopConstraintToNavigationBar(_ shouldConstraintToNavigationBar: Bool) {
        progressBarConstraint?.isActive = false
        if shouldConstraintToNavigationBar {
            progressBarConstraint = progressBar?.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Constants.progressBarHeight)
        } else {
            progressBarConstraint = progressBar?.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -Constants.progressBarHeight)
        }
        progressBarConstraint?.isActive = true
    }
    
    var isProgressBarVisible = false {
        didSet {
            setProgressBarVisible(isProgressBarVisible)
        }
    }
    
    private func setProgressBarVisible(_ isVisible: Bool) {
        progressBarConstraint?.constant = isVisible ? Constants.progressBarHeight : -Constants.progressBarHeight
        }
    
    private func createNavigationProgressBar() -> NavigatorProgressBar {
        let bar = NavigatorProgressBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }
    
    private func updateProgressBarContraints() {}
    
    func setProgressBarVisible(_ progressBarInfo: ProgressBarInfo) {
        progressBar?.updateProgressBar()
        progressBar?.setTopBackgroundViewColor(progressBarInfo.backgroundColor ?? .skyGray)
        guard isProgressBarVisible != progressBarInfo.isVisible else { return }
        isProgressBarVisible = progressBarInfo.isVisible
        progressBar?.setTopBackgroundViewColor(progressBarInfo.backgroundColor ?? .skyGray)
        progressBar?.isHidden = !progressBarInfo.isVisible
    }
    
    func addDelegate(_ delegate: UINavigationControllerDelegate) {
        navigationDelegatesHandler.delegates.append(WeakReference(reference: delegate))
    }
}

extension NavigationController: NavigationStackSemaphore {
    func allowStackChanges() {
        shouldWaitUntilStackChanged = false
    }
}

extension NavigationController {
    private struct Constants {
        static let progressBarHeight = CGFloat(16.0)
    }
}

extension NavigationController: RootMenuController {
    var isSideMenuAvailable: Bool {
        guard let currentViewController = topViewController as? RootMenuController else {
            return false
        }
        return currentViewController.isSideMenuAvailable
    }
}

extension NavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

protocol ModuleViewController {}

private class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    weak var stackSemaphore: NavigationStackSemaphore?
    var delegates: [WeakReference<UINavigationControllerDelegate>] = []
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        stackSemaphore?.allowStackChanges()
        // Workaround to hide the progress bar in Any ViewController that doesnt conforms the ViewControllerProgressBarCapable protocol (for external modules) & Restore the navigation color
        restoreNavigationStyleIfNeeded(of: navigationController, withViewController: viewController)
        disableProgressBarIfNeeded(of: navigationController, withViewController: viewController)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        stackSemaphore?.allowStackChanges()
    }
    
    private func restoreNavigationStyleIfNeeded(of navigationController: UINavigationController, withViewController viewController: UIViewController) {
        // if we are navigating from a viewcontroller of module to a viewcontroller of application
        guard
            let currentViewController = navigationController.viewControllers.first,
            isModuleViewController(currentViewController) || currentViewController is ModuleViewController,
            !isModuleViewController(viewController),
            !isOnboardingViewController(viewController)
        else {
            return
        }
        navigationController.navigationBar.tintColor = .santanderRed
    }
    
    private func disableProgressBarIfNeeded(of navigationController: UINavigationController, withViewController viewController: UIViewController) {
        guard
            let retailNavigationController = navigationController as? NavigationController,
            isModuleViewController(viewController)
        else {
            return
        }
        retailNavigationController.setProgressBarVisible(ProgressBarInfo(isVisible: false, backgroundColor: nil))
    }
    
    private func isModuleViewController(_ viewController: UIViewController) -> Bool {
        return !(viewController is ViewControllerProgressBarCapable)
    }
    
    private func isOnboardingViewController(_ viewController: UIViewController) -> Bool {
        return (viewController is OnboardingClosableProtocol)
    }
}
