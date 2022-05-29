import CoreFoundationLib
import LoginCommon

final class LoginCoordinatorNavigator: ModuleCoordinatorNavigator {
    override var shouldOpenDeepLinkAutomatically: Bool {
        return !sessionManager.isSessionActive
    }
    
    override var shouldRegisterAsDeeplinkHandler: Bool {
        return true
    }
    
    override var launcherAccessType: DeepLinkLauncherAccessType {
        .publicAccess
    }

    func appOpenedFromDeeplink(deeplinkId: String) {
        let pageTrackable = self.dependenciesResolver.resolve(for: PageTrackable.self)
        self.dependencies.trackerManager.trackScreen(
            screenId: pageTrackable.page,
            extraParameters: [TrackerDimensions.deeplinkLogin: deeplinkId])
    }
    
    required init(
        drawer: BaseMenuViewController?,
        dependencies: PresentationComponent,
        navigator: OperativesNavigatorProtocol,
        stringLoader: StringLoader,
        dependenciesEngine: DependenciesInjector & DependenciesResolver,
        coordinatorIdentifier: String
    ) {
        super.init(
            drawer: drawer,
            dependencies: dependencies,
            navigator: navigator,
            stringLoader: stringLoader,
            dependenciesEngine: dependenciesEngine,
            coordinatorIdentifier: coordinatorIdentifier
        )
        self.dependencies.deepLinkManager.register(presentationDelegate: self)
    }
}

extension LoginCoordinatorNavigator: DeepLinkLauncherPresentationProtocol {
    var viewProxy: ViewControllerProxy {
        return self.viewController ?? UIViewController()
    }
}

extension LoginCoordinatorNavigator: QuickBalanceCoordinatorProtocol {
    func didSelectDismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func didSelectOffer(_ offer: OfferEntity, location: PullOfferLocation) {
        executeOffer(action: offer.action, offerId: offer.id, location: location)
    }

    func didSelectDeeplink(_ identifier: String) {
        guard let deeplink = DeepLink(identifier) else { return }
        dependencies.deepLinkManager.registerDeepLink(deeplink)
        viewController?.navigationController?.popViewController(animated: true)
    }
}

extension LoginCoordinatorNavigator: LoginCoordinatorDelegate {
    func goToFakePrivate(isPb: Bool, name: String?) {
        self.navigatorProvider
            .publicHomeNavigator
            .goToFakePrivate(isPb, name)
    }
    
    func backToLogin() {
        self.navigatorProvider
            .publicHomeNavigator.backToLogin()
    }
    
    func goToPrivate(globalPositionOption: GlobalPositionOptionEntity) {
        self.navigatorProvider
            .publicHomeNavigator
            .goToPrivate(globalPositionOption: globalPositionOption)
    }
    
    func goToOtpSca(username: String, isFirstTime: Bool) {
        self.navigatorProvider
            .publicHomeNavigator
            .goToOtpSca(username: username, isFirstTime: isFirstTime)
    }
    
    func reloadSideMenu() {
        self.navigatorProvider
            .publicHomeNavigator.reloadSideMenu()
    }
    
    func didSelectMenu() {
          self.navigatorProvider
              .publicHomeNavigator.toggleSideMenu()
          self.dependencies
            .trackerManager
            .trackScreen(screenId: PublicMenuPage().page, extraParameters: [:])
    }
    
    func goToUrl(urlString: String) {
        self.navigatorProvider
            .publicHomeNavigator.goToURL(source: urlString)
    }
    
    func didSelectOffer(_ offer: OfferEntity) {
        self.executeOffer(offer)
    }
    
    func goToEnvironmentsSelector(completion: @escaping () -> Void) {
        self.navigatorProvider.publicHomeNavigator.goToEnvironmentsSelector {
            completion()
        }
    }
    
    func registerSecuritySettingsDeepLink() {
        self.dependencies
            .deepLinkManager
            .registerDeepLink(DeepLink.securitySettings)
    }
    
    func goToPublic(shouldGoToRememberedLogin: Bool) {
        self.navigatorProvider
            .publicHomeNavigator
            .goToPublic(shouldGoToRememberedLogin: shouldGoToRememberedLogin)
    }
    
    func goToQuickBalance() {
        self.navigatorProvider
            .publicHomeNavigator.goToQuickBalance()
    }
}

extension LoginCoordinatorNavigator: SiriDeleter {}
