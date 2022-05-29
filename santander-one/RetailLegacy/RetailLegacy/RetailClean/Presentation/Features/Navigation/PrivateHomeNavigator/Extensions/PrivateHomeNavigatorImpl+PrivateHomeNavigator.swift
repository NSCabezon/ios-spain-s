import CoreFoundationLib
import PersonalManager
import GlobalPosition
import GlobalSearch
import PersonalArea
import Transfer
import Account
import Cards
import Menu
import CoreDomain

extension PrivateHomeNavigatorImpl: PrivateHomeNavigator {
    func didSelectGoToBranchLocator() {
        goToATMLocator(keepingNavigation: true)
    }
    
    func present(selectedProduct: GenericProduct? = nil, productHome: PrivateMenuProductHome) {
        self.productsNavigator.presentProduct(selectedProduct: selectedProduct, productHome: productHome, overCurrentController: false)
    }
    
    func showCardTransaction(_ transaction: CardTransactionEntity, in transactions: [CardTransactionWithCardEntity], for entity: CardEntity) {
        self.presenterProvider.dependenciesEngine.register(for: CardTransactionDetailConfiguration.self) { _ in
            return CardTransactionDetailConfiguration(selectedCard: entity, selectedTransaction: transaction, resultTransactions: transactions)
        }
        self.productsNavigator.showCardsHome(with: entity, cardSection: .detail)
    }
    
    func showAccountTransaction(_ transaction: AccountTransactionEntity, in transactions: [AccountTransactionWithAccountEntity], for entity: AccountEntity, associated: Bool) {
        self.presenterProvider.dependenciesEngine.register(for: AccountTransactionDetailConfiguration.self) { _ in
            return AccountTransactionDetailConfiguration(selectedAccount: entity, selectedTransaction: transaction, resultTransactions: transactions)
        }
        self.productsNavigator.showAccountsHome(with: entity, accountSection: associated ? .detail : .detailWithOutAssociated)
    }
    
    func goToTransfers(section: TransferModuleCoordinator.TransferSection) {
        launchTransferSection(section)
    }
    
    func goToNewShipment() {
        launchTransferSection(.newShipment)
    }
    
    func goToInternalTransfers() {
        launchTransferSection(.internalTransfer)
    }
    
    func open(url: String) {
        guard let source = URL(string: url), canOpen(source) else {
            return
        }
        open(source)
    }
    
    func backToGlobalPosition() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        navigationController?.popToRootViewController(animated: true)
    }
    
    func setOnlyFirstViewControllerToGP() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        if let globalPositionVC = navigationController?.viewControllers.first {
            navigationController?.setViewControllers([globalPositionVC], animated: false)
        }
    }
    
    func setFirstViewControllerToGP() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        if let globalPositionVC = navigationController?.viewControllers.first, let lastVC: UIViewController = navigationController?.viewControllers.last {
            guard globalPositionVC != lastVC else { return }
            navigationController?.setViewControllers([globalPositionVC, lastVC], animated: false)
        }
    }
    
    func goToManager() {
        presenterProvider.dependenciesEngine.register(for: PersonalManagerConfiguration.self ) { _ in
            return PersonalManagerConfiguration(sharedTokenAccessGroup: self.compilation.keychain.sharedTokenAccessGroup)
        }
        presenterProvider.dependenciesEngine.register(for: PersonalManagerMainModuleCoordinatorDelegate.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: PersonalManagerHomeCoordinatorNavigator.self)
        }
        personalManagerCoordinator.start(.withManager)
    }
    
    func goToGlobalSearch() {
        presenterProvider.dependenciesEngine.register(for: GlobalSearchMainModuleCoordinatorDelegate.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: GlobalSearchHomeCoordinatorNavigator.self)
        }
        globalSearchCoordinator.start(.main)
    }
    
    func goToSecureDeviceOperative() {
        personalAreaCoordinator.start(.secureDeviceOperative)
    }
    
    func goToSecureDevice(device: OTPPushDeviceEntity?) {
        legacyExternalDependenciesResolver
            .personalAreaSecurityCoordinator()
            .set(device)
            .start()
    }
    
    func goToDigitalProfile() {
        legacyExternalDependenciesResolver
            .personalAreaDigitalProfileCoordinator()
            .start()
    }
    
    func goToPersonalArea() {
        legacyExternalDependenciesResolver
            .personalAreaHomeCoordinator()
            .start()
    }

    func goToAppPermissions() {
        legacyExternalDependenciesResolver
            .personalAreaAppPermissionsCoordinator()
            .start()
    }

    func goToSecuritySettings() {
        legacyExternalDependenciesResolver
            .personalAreaSecurityCoordinator()
            .start()
    }
    
    func goToConfiguration() {
        legacyExternalDependenciesResolver
            .personalAreaConfigurationCoordinator()
            .start()
    }
    
    func goToConfigureGP() {
        legacyExternalDependenciesResolver
            .personalAreaPGPersonalizationCoordinator()
            .start()
    }
    
    func goToProductsCustomization() {
        legacyExternalDependenciesResolver
            .personalAreaPGPersonalizationCoordinator()
            .start()
    }
    
    func goToUserBasicInfo() {
        legacyExternalDependenciesResolver
            .personalAreaBasicInfoCoordinator()
            .start()
    }
    
    func goToGPCustomization() {
        personalAreaCoordinator.start(.customizeGP)
    }

    func goToGPProductsCustomization() {
        let coordinator = GPCustomizationCoordinator(dependenciesResolver: dependenciesEngine,
                                                     navigationController: self.navigationController)
        coordinator.start()
    }
    
    func registerPersonalAreaDependencies() {
        presenterProvider.dependenciesEngine.register(for: PersonalAreaConfiguration.self) { dependenciesResolver in
            let pushNotificationManager = dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
            let locationManager = dependenciesResolver.resolve(for: LocationPermissionsManagerProtocol.self)
            let localAuthManager = dependenciesResolver.resolve(for: LocalAuthenticationPermissionsManagerProtocol.self)
            let contactsManager = dependenciesResolver.resolve(for: ContactPermissionsManagerProtocol.self)
            
            return PersonalAreaConfiguration(pushNotificationPermissionsManager: pushNotificationManager, locationPermissionsManager: locationManager, localAuthPermissionsManager: localAuthManager, contactsPermissionsManager: contactsManager)
        }
        presenterProvider.dependenciesEngine.register(for: LocationPermissionSettingsProtocol.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: PersonalAreaCoordinatorNavigator.self)
        }
        presenterProvider.dependenciesEngine.register(for: PersonalAreaMainModuleCoordinatorDelegate.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: PersonalAreaCoordinatorNavigator.self)
        }
    }
    
    func goToHelpCenter() {
        presenterProvider.dependenciesEngine.register(for: HelperCenterCoordinatorProtocol.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
        }
        presenterProvider.dependenciesEngine.register(for: PersonalAreaMainModuleCoordinatorDelegate.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: PersonalAreaCoordinatorNavigator.self)
        }
        menuCoordinator.start(.helpCenter)
    }
    
    func goToSecurityArea() {
        registerPersonalAreaDependencies()
        self.presenterProvider.dependenciesEngine.register(for: SecurityAreaCoordinatorDelegate.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: PersonalAreaCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: TripListCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: PersonalAreaCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: NoTripCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: PersonalAreaCoordinatorNavigator.self)
        }
        self.personalAreaCoordinator.start(.securityArea)
    }
    
    func goToServicesForYou(with category: Category) {
        let presenter = presenterProvider.servicesForYouPresenter(category: category)
        guard let navigator = drawer.currentRootViewController as? NavigationController else { return }
        if let globalPositionVC = navigator.viewControllers.first {
            navigator.setViewControllers([globalPositionVC, presenter.view], animated: true)
        }
    }
    
    func goToVariableIncome() {
        let variableIncomePresenter = presenterProvider.variableIncomePresenter()
        guard let navigation = drawer.currentRootViewController as? NavigationController else { return }
        navigation.popToRootViewController(animated: false)
        navigation.pushViewController(variableIncomePresenter.view, animated: true)
    }
    
    func goToVisualOptions() {
        guard let navigator = drawer.currentRootViewController as? NavigationController else { return }
        if let globalPositionVC = navigator.viewControllers.first {
            navigator.setViewControllers([globalPositionVC, presenterProvider.visualOptionsPresenter.view], animated: true)
        }
    }
    
    func goToChangeDirectLinkConfiguration() {
        guard let navigator = drawer.currentRootViewController as? NavigationController else { return }
        if let globalPositionVC = navigator.viewControllers.first {
            navigator.setViewControllers([globalPositionVC, presenterProvider.personalAreaFrequentOperativesPresenter().view], animated: true)
        }
    }
    
    func presentOverCurrentController(selectedProduct: GenericProduct? = nil, productHome: PrivateMenuProductHome) {
        self.productsNavigator.presentProduct(selectedProduct: selectedProduct, productHome: productHome, overCurrentController: true)
    }
    
    func goToOnboarding(delegate: OnboardingDelegate, onboardingUserData: OnboardingUserData) {
        guard let navigation = drawer.currentRootViewController as? NavigationController, let globalPositionVC = navigation.viewControllers.first else { return }
        let onboardingPresenter = presenterProvider.onboardingWelcomePresenter
        onboardingPresenter.delegate = delegate
        onboardingPresenter.onboardingUserData = onboardingUserData
        
        navigation.setViewControllers([globalPositionVC, onboardingPresenter.view], animated: true)
    }
    
    func goToStockholders() {
        let coordinator = dependenciesEngine.resolve(for: RetailLegacyExternalDependenciesResolver.self).publicMenuStockholdersCoordinator()
        coordinator.start()
    }
    
    func goToWhatsNew() {
        let coordinator = WhatsNewCoordinator(resolver: presenterProvider.dependenciesEngine, navigationController: customNavigation ?? UINavigationController())
        coordinator.startWithOutFakeAnimation()
    }
    
    func goToWhatsNewFractionalMovements() {
        let coordinator = LastMovementsCoordinator(dependenciesResolver: presenterProvider.dependenciesEngine, navigationController: customNavigation ?? UINavigationController())
        coordinator.start()
    }
    
    func goToHistoricSendMoney() {
        launchTransferSection(.historical)
    }
    
    func gotoCardSubcriptions() {
        self.presenterProvider.dependenciesEngine.register(for: CardsHomeModuleCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: CardControlDistributionConfiguration.self) { _ in
            return CardControlDistributionConfiguration(card: nil)
        }
        let coordinator = CardControlDistributionCoordinator(
            dependenciesResolver: presenterProvider.dependenciesEngine,
            navigationController: customNavigation ?? UINavigationController(),
            externalDependencies: cardExternalDependencies
        )
        coordinator.start()
    }
    
    func goToTips() {
        let coordinator = dependenciesEngine.resolve(for: RetailLegacyExternalDependenciesResolver.self).publicMenuHomeTipsCoordinator()
        coordinator.start()
    }
    
    func gotoNextSettlement(_ cardEntity: CardEntity, cardSettlementDetailEntity: CardSettlementDetailEntity, isEnabledMap: Bool) {
        let coordinator = NextSettlementCoordinator(dependenciesResolver: presenterProvider.dependenciesEngine,
                                                    navigationController: customNavigation ?? UINavigationController(),
                                                    externalDependencies: self.cardExternalDependencies)
        dependenciesEngine.register(for: NextSettlementConfiguration.self) { _ in
            return NextSettlementConfiguration(card: cardEntity,
                                               cardSettlementDetailEntity: cardSettlementDetailEntity,
                                               isMultipleMapEnabled: isEnabledMap)
        }
        coordinator.start()
    }

    func gotoCardEasyPayOperative(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?) {
        self.presenterProvider.dependenciesEngine.register(for: CardsHomeModuleCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        let coordinator = CardsHomeModuleCoordinator(
            dependenciesResolver: self.presenterProvider.dependenciesEngine,
            navigationController: self.navigationController ?? UINavigationController(),
            externalDependencies: cardExternalDependencies
        )
        coordinator.easyPay(
            entity: card,
            transactionEntity: transaction,
            easyPayOperativeDataEntity: easyPayOperativeData
        )
    }
    
    func goToFractionedPaymentDetail(transaction: CardTransactionEntity, card: CardEntity) {
        let booleanFeatureFlag: BooleanFeatureFlag = dependenciesEngine.resolve()
        booleanFeatureFlag.fetch(CoreFeatureFlag.cardTransactionDetail)
            .filter { $0 == true }
            .sink { [unowned self] _ in
                cardExternalDependencies
                    .cardTransactionDetailCoordinator()
                    .set(card.representable)
                    .set(transaction.representable)
                    .start()
            }.store(in: &subscriptions)
        
        booleanFeatureFlag.fetch(CoreFeatureFlag.cardTransactionDetail)
            .filter { $0 == false }
            .sink { [unowned self] _ in
                self.dependenciesEngine.register(for: CardTransactionDetailConfiguration.self) { _ in
                    return CardTransactionDetailConfiguration(
                        selectedCard: card,
                        selectedTransaction: transaction,
                        allTransactions: [transaction]
                    )
                }
                let coordinator = OldCardTransactionDetailCoordinator(
                    dependenciesResolver: self.dependenciesEngine,
                    navigationController: self.navigationController ?? UINavigationController(),
                    externalDependencies: self.cardExternalDependencies
                )
                coordinator.start()
            }.store(in: &subscriptions)
    }
}

extension PrivateHomeNavigatorImpl: PrivateHomeNavigatorLauncher {}
