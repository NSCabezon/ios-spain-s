import CoreFoundationLib
import FinantialTimeline
import GlobalPosition
import CoreDomain
import Transfer
import Bills
import Menu

extension PrivateHomeNavigatorImpl: PrivateHomeNavigatorSideMenu {
    func goToAnalysisArea() {
        guard let isEnabledFinacialHealthUseCase = self.dependenciesEngine.resolve(forOptionalType: GetIsEnabledFinancialHealthUseCase.self) else {
            self.presenterProvider.dependenciesEngine.register(for: OldAnalysisAreaCoordinatorDelegate.self ) { _ in
                return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
            }
            self.menuCoordinator.start(.oldAnalysisArea)
            return
        }
        Scenario(useCase: isEnabledFinacialHealthUseCase)
            .execute(on: self.presenterProvider.dependenciesEngine.resolve())
            .onSuccess { result in
                if result.isEnabledFinancialHealthZone {
                    self.legacyExternalDependenciesResolver
                        .analysisAreaHomeCoordinator()
                        .start()
                } else {
                    self.presenterProvider.dependenciesEngine.register(for: OldAnalysisAreaCoordinatorDelegate.self ) { _ in
                        return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
                    }
                    self.menuCoordinator.start(.oldAnalysisArea)
                }
            }
    }

    func goToContractView() {
        guard let navigator = drawer.currentRootViewController as? NavigationController else { return }
        if let globalPositionVC = navigator.viewControllers.first {
            navigator.setViewControllers([globalPositionVC, presenterProvider.publicProductsPresenter.view], animated: true)
        }
    }
    
    var drawerRoot: RootableViewController? {
        return drawer.currentRootViewController
    }
    
    var highlight: HighlightedMenuProtocol? {
        let high = self.customNavigation?.viewControllers.compactMap({ $0 as? HighlightedMenuProtocol }).last
        return high
    }
    
    func drawerRoot<T>(as: T.Type) -> T? {
        guard let root = drawer.currentRootViewController as? T else {
            let navigation = drawer.currentRootViewController as? NavigationController
            return navigation?.viewControllers.last as? T
        }
        return root
    }
    
    func goToMyProducts(privateMenuWrapper: PrivateMenuWrapper, offerDelegate: PrivateSideMenuOfferDelegate) {
        guard let navigationController = drawer.currentSideMenuViewController as? UINavigationController else {
            return
        }
        let presenter = presenterProvider.myProductsSideMenuPresenter(privateMenuWrapper: privateMenuWrapper, offerDelegate: offerDelegate)
        navigationController.pushViewController(presenter.view, animated: true)
    }
    
    func goToSofiaInvestment(privateMenuWrapper: PrivateMenuWrapper, offerDelegate: PrivateSideMenuOfferDelegate) {
        guard let navigationController = drawer.currentSideMenuViewController as? UINavigationController else {
            return
        }
        let presenter = presenterProvider.sofiaSideMenuPresenter(privateMenuWrapper: privateMenuWrapper, offerDelegate: offerDelegate)
        navigationController.pushViewController(presenter.view, animated: true)
    }
    
    func goToOtherServices(privateMenuWrapper: PrivateMenuWrapper, offerDelegate: PrivateSideMenuOfferDelegate, comingFeatures: Bool) {
        guard let navigationController = drawer.currentSideMenuViewController as? UINavigationController else {
            return
        }
        let presenter = presenterProvider.otherServicesMenuPresenter(privateMenuWrapper: privateMenuWrapper,
                                                                     offerDelegate: offerDelegate,
                                                                     comingFeatures: comingFeatures)
        navigationController.pushViewController(presenter.view, animated: true)
    }
    
    func goToServicesForYouHelper(offerDelegate: PrivateSideMenuOfferDelegate) {
        guard let navigationController = drawer.currentSideMenuViewController as? UINavigationController else {
            return
        }
        navigationController.pushViewController(presenterProvider.myServicesForYouSideMenuPresenter(offerDelegate: offerDelegate).view, animated: true)
    }
    
    func goToWorld123(privateMenuWrapper: PrivateMenuWrapper, offerDelegate: PrivateSideMenuOfferDelegate, comingFeatures: Bool) {
        guard let navigationController = drawer.currentSideMenuViewController as? UINavigationController else {
            return
        }
        let presenter = presenterProvider.world123MenuPresenter(privateMenuWrapper: privateMenuWrapper,
                                                                offerDelegate: offerDelegate,
                                                                comingFeatures: comingFeatures)
        navigationController.pushViewController(presenter.view, animated: true)
    }
    
    func goToBillsAndTaxes() {
        self.presenterProvider.dependenciesEngine.register(for: BillConfiguration.self) { _ in
            return BillConfiguration(account: nil)
        }
        self.presenterProvider.dependenciesEngine.register(for: BillHomeModuleCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: BillsHomeCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: DirectDebitCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: BillsHomeCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: PaymentCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: BillsHomeCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: BillSearchFiltersCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: BillsHomeCoordinatorNavigator.self)
        }
        self.billsModuleCoordinator.start(.home)
    }
    
    func goToFutureBill(_ bill: AccountFutureBillRepresentable, in bills: [AccountFutureBillRepresentable], for entity: AccountEntity) {
        self.presenterProvider.dependenciesEngine.register(for: BillHomeModuleCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: BillsHomeCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: BillConfiguration.self) { _ in
            return BillConfiguration(account: entity)
        }
        self.billsModuleCoordinator.goToFutureBill(bill, in: bills, for: entity)
    }
    
    func goToDirectDebitBillAndTaxes(_ account: AccountEntity?) {
        self.dependenciesEngine.register(for: DirectDebitConfiguration.self) { _ in
            return DirectDebitConfiguration(account: account)
        }
        self.presenterProvider.dependenciesEngine.register(for: BillHomeModuleCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: BillsHomeCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: DirectDebitCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: BillsHomeCoordinatorNavigator.self)
        }
        self.billsModuleCoordinator.start(.directDebit)
    }
    
    func didSelectContact(_ contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate) {
        self.dependenciesEngine.register(for: ContactDetailCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: TransfersHomeCoordinatorNavigator.self)
        }
        self.dependenciesEngine.register(for: TransfersHomeConfiguration.self) { _ in
            return TransfersHomeConfiguration(selectedAccount: nil, isScaForTransactionsEnabled: false)
        }
        self.presenterProvider.dependenciesEngine.register(for: ContactDetailConfiguration.self) { resolver in
            let transferConfiguration = resolver.resolve(for: TransfersHomeConfiguration.self)
            return ContactDetailConfiguration(contact: contact, account: transferConfiguration.selectedAccount)
        }
        self.contactsDetailCoordinator.start(withLauncher: launcher, handleBy: delegate)
    }
    
    func popToFirstLevel(animated: Bool) {
        guard let navigationController = drawer.currentSideMenuViewController as? UINavigationController else {
            return
        }
        navigationController.popToRootViewController(animated: animated)
    }
    
    func goBack(animated: Bool) {
        guard let navigationController = drawer.currentSideMenuViewController as? UINavigationController else {
            return
        }
        navigationController.popViewController(animated: animated)
    }
    
    func reloadPrivate() {
        let pgCoordinator: GlobalPositionModuleCoordinator = dependenciesEngine.resolve(for: GlobalPositionModuleCoordinator.self)
        dependenciesEngine.register(for: GlobalPositionModuleCoordinatorDelegate.self) { resolver in
            return resolver.resolve(for: NavigatorProvider.self).getModuleCoordinator(type: GlobalPositionModuleCoordinatorNavigator.self)
        }
        dependenciesEngine.register(for: LoanSimulatorOfferDelegate.self) { resolver in
            return resolver.resolve(for: NavigatorProvider.self).getModuleCoordinator(type: GlobalPositionModuleCoordinatorNavigator.self)
        }
        dependenciesEngine.register(for: GetInfoSideMenuUseCaseProtocol.self) { _ in
            return GetInfoSideMenuUseCase(dependenciesResolver: self.dependenciesEngine)
        }
        let navigationController: NavigationController = NavigationController()
        drawer.setRoot(viewController: navigationController)
        pgCoordinator.navigationController = navigationController
        pgCoordinator.start(.simple)
        
        drawer.setRoot(viewController: navigationController)
        let coordinator = self.presenterProvider.navigatorProvider.legacyExternalDependenciesResolver.privateMenuCoordinator()
        coordinator.start()
        drawer.setSideMenu(viewController: coordinator.navigationController)
    }
    
    func goToFinancing() {
        presenterProvider.dependenciesEngine.register(for: FinancingCoordinatorDelegate.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
        }
        presenterProvider.dependenciesEngine.register(for: AccountFinanceableTransactionCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
        }
        presenterProvider.dependenciesEngine.register(for: FinanceableTransactionCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
        }
        self.menuCoordinator.start(.financing)
    }
    
    func goToAtm() {
        let localAppConfig = self.dependenciesEngine.resolve(for: LocalAppConfig.self)
        if localAppConfig.showATMIntermediateScreen {
            presenterProvider.dependenciesEngine.register(for: AtmCoordinatorDelegate.self ) { _ in
                return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
            }
            self.menuCoordinator.start(.atm)
        } else {
            goToATMLocator(keepingNavigation: true)
        }
    }
    
    func goToComingSoon() {
        presenterProvider.dependenciesEngine.register(for: ComingFeaturesCoordinatorDelegate.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
        }
        self.menuCoordinator.start(.comingFeatures)
    }
    
    func goToTimeline() {
        let timeLine = TimeLine.load()
        guard let navigation = drawer.currentRootViewController as? NavigationController else { return }
        navigation.pushViewController(timeLine, animated: true)
    }
    
    func showComingSoonToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}
