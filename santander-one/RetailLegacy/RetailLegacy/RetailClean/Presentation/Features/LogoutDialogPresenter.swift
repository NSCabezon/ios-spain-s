import Foundation
import CoreFoundationLib

final class LogoutDialogPresenter: PrivatePresenter<LogoutDialogViewController, LogoutDialogNavigator, LogoutDialogPresenterProtocol> {
    
    private let acceptAction: () -> Void
    private let offerDidOpenAction: () -> Void
    private var offer: Offer?
    private var isLogoutLocation: Bool = true
    
    private lazy var logoutByePresenter: LogoutByePresenter = {
        return navigator.presenterProvider.logoutByePresenter
    }()
    private weak var container: UIViewController?
    
    private var presentationTimer: Timer?
    private var byeTimer: Timer?
    
    var remainingTimeForViewDismission: Int = 5
    var totalTimeForViewDismission: Int = 5
    
    // MARK: - Public methods
    
    init(dependencies: PresentationComponent,
         sessionManager: CoreSessionManager,
         navigator: LogoutDialogNavigator,
         acceptAction: @escaping () -> Void,
         offerDidOpenAction: @escaping () -> Void) {
        
        self.acceptAction = acceptAction
        self.offerDidOpenAction = offerDidOpenAction
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func viewWillAppear() {
        performTracks()
        dependencies.siriIntentsManager.delegate = self
    }
    
    public func presentIn(_ viewController: UIViewController) {
        self.container = viewController
        getOffer()
    }
    
    private func getOffer() {
        let useCase = dependencies.useCaseProvider.getLogoutDialogUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, onSuccess: { result in
            guard
                let offer = result.offer,
                let url = offer.banners.first?.url
                else {
                    self.presentByeView(replacing: false)
                    return
            }
            self.offer = offer
            self.isLogoutLocation = result.isLogoutLocation
            let model = ImageBannerViewModel(url: url,
                                             bannerOffer: offer,
                                             isClosable: false,
                                             isRounded: false,
                                             actionDelegate: self,
                                             dependencies: self.dependencies)
            self.view.imageBannerViewModel = model
            self.presentLogoutDialog()
        })
    }
    
    private func presentLogoutDialog() {
        self.view.modalPresentationStyle = .overCurrentContext
        self.view.modalTransitionStyle = .crossDissolve
        self.container?.present(self.view, animated: true)
    }
    
    private func countdownValue(_ time: Int) {
        self.remainingTimeForViewDismission = time
        self.view.setCountdownValue(String(format: "00:%02d", time))
        presentationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] in
            $0.invalidate()
            time > 0 ? self?.countdownValue(time - 1) : self?.didEndCountdown()
        }
    }
    
    func didEndCountdown() {
        presentByeView(replacing: true)
    }
    
    private func presentByeView(replacing: Bool) {
        guard replacing else { return self.showBye() }
        self.view.dismiss(animated: false) { [weak self] in
            self?.showBye()
        }
    }
    
    private func showBye() {
        guard let container = container else { return }
        dismissModalsIfNeeded(on: container) { [weak self] in
            self?.logoutByePresenter.presentIn(container,
                                               completeAction: self?.acceptAction)
        }
    }
    
    private func dismissModalsIfNeeded(on view: UIViewController, completion: @escaping () -> Void) {
        guard let drawer = view as? BaseMenuViewController,
            let currentViewController = drawer.currentRootViewController as? NavigationController,
            let lastViewController = currentViewController.viewControllers.last?.presentedViewController
            else { return completion() }
        lastViewController.dismiss(animated: false, completion: completion)
    }
}

extension LogoutDialogPresenter: LogoutDialogPresenterProtocol {
    func didSelectClose() {
        self.navigator.dismiss()
    }
    
    func viewDidLoad() {
        self.view.setCountdownValue(String(format: "00:%02d", totalTimeForViewDismission))
    }
    
    func didSelectLogout() {
        presentationTimer?.invalidate()
        presentByeView(replacing: true)
    }
    
    func stopTimer() {
        presentationTimer?.invalidate()
        presentationTimer = nil
    }
    
    func restartTimer() {
        self.view.startCountdownProgress(Double(remainingTimeForViewDismission))
        countdownValue(remainingTimeForViewDismission)
    }
    
    func startDialogCountdown() {
        self.view.startCountdownProgress(Double(totalTimeForViewDismission))
        self.countdownValue(totalTimeForViewDismission)
    }
}

extension LogoutDialogPresenter: LocationBannerDelegate {
    
    func closeBanner(bannerOffer: Offer?) {
        removeOffer()
        presentByeView(replacing: true)
    }
    
    func finishDownloadImage(newHeight: Float?) {
        view.showBanner(newHeight: newHeight)
    }
    
    func selectedBanner() {
        presentationTimer?.invalidate()
        navigator.dismiss()
        guard let offer = self.offer, let offerAction = offer.action else { return }
        self.executeOffer(action: offerAction,
                          offerId: offer.id,
                          location: self.isLogoutLocation ? PullOfferLocation.LOGOUT_DIALOG : nil)
        
        self.removeOffer()
        self.offerDidOpenAction()
    }
    
    private func removeOffer() {
        guard let offer = offer else { return }
        guard !isLogoutLocation else { return removeOffer(location: .LOGOUT_DIALOG) }
        
        let input = DisableOnSessionPullOfferUseCaseInput(offerId: offer.id)
        UseCaseWrapper(with: dependencies.useCaseProvider.getDisableOnSessionPullOfferUseCase(input: input),
                       useCaseHandler: dependencies.useCaseHandler)
    }
}

extension LogoutDialogPresenter: PullOfferActionsPresenter {
    
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}
