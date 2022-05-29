import GlobalPosition
import CoreFoundationLib
import FinantialTimeline
import SANLegacyLibrary
import UI
import Cards
import PersonalArea
import Transfer
import Operative
import CoreDomain
import Onboarding
import Menu
import OpenCombine

final class GlobalPositionModuleCoordinatorNavigator: ModuleCoordinatorNavigator {
    private let loginMessages: LoginMessages = LoginMessages()
    private var loginMessagesCurrentState: LoginMessagesState?
    private var currentGP: GlobalPositionOption?
    private var isGPChanged: Bool?
    private var subscriptions: Set<AnyCancellable> = []
    private weak var bubbleBanner: BubbleBannerView?
    private lazy var storeProductViewControllerDelegate = StoreProductViewControllerDelegate()
    private var permissionsStatusWrapper: PermissionsStatusWrapperProtocol {
        return self.dependenciesResolver.resolve(for: PermissionsStatusWrapperProtocol.self)
    }
    private var localAuthentication: LocalAuthenticationPermissionsManagerProtocol {
        return self.permissionsStatusWrapper.getLocalAuthenticationPermissionsManagerProtocol()
    }
    private var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    override var shouldOpenDeepLinkAutomatically: Bool {
        return loginMessagesCurrentState == .finished
    }
    private var onePayDelegate: OnePayCollectionDelegateProtocol? {
        self.dependenciesResolver.resolve(forOptionalType: OnePayCollectionDelegateProtocol.self)
    }
    private var notificationPermissionsManager: PushNotificationPermissionsManagerProtocol? {
        self.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }
    private var universalLinkManager: UniversalLinkManagerProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: UniversalLinkManagerProtocol.self)
    }
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        self.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    private lazy var onboardingCoordinator = dependenciesResolver.resolve(for: RetailLegacyExternalDependenciesResolver.self).onboardingCoordinator()
    
    
    private var tokenIdUseCase: GetCarbonFootprintIdUseCase {
        self.dependenciesResolver.resolve()
    }
    
    private var tokenDataUseCase: GetCarbonFootprintDataUseCase {
        self.dependenciesResolver.resolve()
    }
    
    private var carbonFootprintWebViewConfigurationUseCase: GetCarbonFootprintWebViewConfigurationUseCase {
        self.dependenciesResolver.resolve()
    }

    required init(drawer: BaseMenuViewController?, dependencies: PresentationComponent, navigator: OperativesNavigatorProtocol, stringLoader: StringLoader, dependenciesEngine: DependenciesInjector & DependenciesResolver, coordinatorIdentifier: String) {
        super.init(drawer: drawer, dependencies: dependencies, navigator: navigator, stringLoader: stringLoader, dependenciesEngine: dependenciesEngine, coordinatorIdentifier: coordinatorIdentifier)
        self.dependencies.deepLinkManager.register(presentationDelegate: self)
        self.universalLinkManager?.registerPresenting(self)
    }
    
    func goToFutureBill(_ bill: AccountFutureBillRepresentable, in bills: [AccountFutureBillRepresentable], for entity: AccountEntity) {
        navigatorProvider.privateHomeNavigator.goToBillsAndTaxes()
    }
    
    func didSelectAccount(account: AccountEntity) {
        self.navigatorProvider.privateHomeNavigator.present(selectedProduct: Account(account), productHome: .accounts)
    }
    
    func didSelectAccountMovement(movement: AccountTransactionEntity, in account: AccountEntity) {
        let account = Account(account)
        navigatorProvider.privateHomeNavigator.present(selectedProduct: account, productHome: .accounts)
        navigatorProvider.productHomeNavigator.goToTransactionDetail(product: account, transactions: [movement].map({ AccountTransaction($0.dto) }), selectedPosition: 0, productHome: .accounts, syncDelegate: nil, optionsDelegate: nil)
    }
    
    func didSelectCard(card: CardEntity) {
        if localAppConfig.isEnabledCardDetail {
            navigatorProvider.privateHomeNavigator.present(selectedProduct: Card(card), productHome: .cards)
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectFund(fund: FundEntity) {
        if self.dependencies.localAppConfig.isEnabledfundWebView {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        } else {
            navigatorProvider.privateHomeNavigator.present(selectedProduct: Fund(fund), productHome: .funds)
        }
    }
    
    func didSelectInsuranceSaving(insurance: InsuranceSavingEntity) {
        if self.dependencies.localAppConfig.enableInsuranceSavingHome {
            navigatorProvider.privateHomeNavigator.present(selectedProduct: InsuranceSaving(insurance), productHome: .insuranceSavings)
        }
    }
    
    func didSelectInsuranceProtection(insurance: InsuranceProtectionEntity) {
        navigatorProvider.privateHomeNavigator.present(selectedProduct: InsuranceProtection(insurance), productHome: .insuranceProtection)
    }
    
    func didSelectDeposit(deposit: DepositEntity) {
        if self.dependencies.localAppConfig.isEnabledDepositWebView {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        } else {
            navigatorProvider.privateHomeNavigator.present(selectedProduct: Deposit(deposit), productHome: .deposits)
        }
    }
    
    func didSelectLoan(loan: LoanEntity) {
        if self.dependencies.localAppConfig.clickableLoan {
            navigatorProvider.privateHomeNavigator.present(selectedProduct: Loan(loan), productHome: .loans)
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectPension(pension: PensionEntity) {
        if self.dependencies.localAppConfig.enablePensionsHome {
            navigatorProvider.privateHomeNavigator.present(selectedProduct: Pension(pension), productHome: .pensions)
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectPortfolio(portfolio: PortfolioEntity) {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func didSelectManagedPortfolio(portfolio: PortfolioEntity) {
        navigatorProvider.privateHomeNavigator.present(selectedProduct: Portfolio(portfolio), productHome: .managedPortfolios)
    }
    
    func didSelectNotManagedPortfolio(portfolio: PortfolioEntity) {
        navigatorProvider.privateHomeNavigator.present(selectedProduct: Portfolio(portfolio), productHome: .notManagedPortfolios)
    }
    
    func didSelectStockAccount(stockAccount: StockAccountEntity) {
        if self.dependencies.localAppConfig.enablePortfoliosHome {
            guard let modifier = dependenciesResolver.resolve(forOptionalType: StockAccountsHomeModifierProtocol.self) else {
                navigatorProvider.privateHomeNavigator.present(selectedProduct: StockAccount(stockAccount), productHome: .stocks)
                return
            }
            modifier.didSelectStockAccount()
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectSavingProduct(savingProduct: SavingProductEntity) {
        if self.dependencies.localAppConfig.isEnabledSavings {
            self.navigatorProvider.privateHomeNavigator.present(selectedProduct: SavingProduct(savingProduct), productHome: .savingProducts)
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectOffer(offer: OfferEntity, in location: PullOfferLocation) {
        self.executeOffer(offer)
    }
    
    func didSelectMenu() {
        drawer?.toggleSideMenu()
    }
    
    func addFavourite() {
        if self.dependenciesResolver.resolve(forOptionalType: PreValidateNewFavouriteUseCaseProtocol.self) != nil {
            self.goToNewFavourite(handler: self)
        } else {
            self.showCreateUsualTransfer(delegate: self)
        }
    }
    
    func goToNewShipment() {
        if let onePayDelegate = onePayDelegate {
            if onePayDelegate.canGoToNewShipment() {
                navigatorProvider.privateHomeNavigator.goToNewShipment()
            }
        } else {
            navigatorProvider.privateHomeNavigator.goToNewShipment()
        }
    }
    
    func globalPositionDidLoad() {
        self.loginMessages.delegate = self
    }
    
    func globalPositionDidAppear() {
        if !dependencies.deepLinkManager.isDeepLinkScheduled() {
            loginMessages.resume()
        } else {
            dependencies.deepLinkManager.performScheduledDeepLink()
        }
        self.universalLinkManager?.launchWithPresentingIfNeeded()
    }
    
    func globalPositionDidDisappear() {
        self.loginMessages.isPaused = true
        bubbleBanner?.close()
    }
    
    func globalPositionDidReload() {}
    
    func didSelectContract() {
        self.goToPublicProducts(delegate: self, location: PullOfferLocation.CONTRATAR_SANFLIX)
    }
    
    func didSelectReceipt() {
        navigatorProvider.privateHomeNavigator.goToBillsAndTaxes()
    }
    
    func didSelectSendMoney() {
        let booleanFeatureFlag: BooleanFeatureFlag = self.dependencies.useCaseProvider.dependenciesResolver.resolve()
        booleanFeatureFlag.fetch(CoreFeatureFlag.transferHome)
            .filter { $0 == true }
            .sink { [unowned self] _ in
                self.dependencies.navigatorProvider.legacyExternalDependenciesResolver.oneTransferHomeCoordinator().start()
            }.store(in: &subscriptions)
        booleanFeatureFlag.fetch(CoreFeatureFlag.transferHome)
            .filter { $0 == false }
            .sink { [unowned self] _ in
                self.navigatorProvider.privateHomeNavigator.goToTransfers(section: .home)
            }.store(in: &subscriptions)
    }
    
    func didSelectATM() {
        navigatorProvider.privateHomeNavigator.goToAtm()
    }
    
    func didSelectFinancing() {
        dependencies.deepLinkManager.registerDeepLink(DeepLink.financing)
    }
    
    func didSelectConsultPin() {
        dependencies.deepLinkManager.registerDeepLink(DeepLink.pinQuery)
    }
    
    func didSelectAnalysisArea() {
        if self.localAppConfig.isEnabledAnalysisArea {
            self.navigatorProvider.privateHomeNavigator.goToAnalysisArea()
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectStockholders() {
        navigatorProvider.privateHomeNavigator.goToStockholders()
    }
    
    func didSelectCustomerService() {
        navigatorProvider.privateHomeNavigator.goToHelpCenter()
    }
    
    func didSelectManager() {
        navigatorProvider.privateHomeNavigator.goToManager()
    }
    
    func didSelectPersonalArea() {
        navigatorProvider.privateHomeNavigator.goToPersonalArea()
    }
    
    func didSelectConfigureGP() {
        navigatorProvider.privateHomeNavigator.goToConfigureGP()
    }

    func didSelectConfigureGPProducts() {
        navigatorProvider.privateHomeNavigator.goToGPProductsCustomization()
    }
    
    func didSelectMarketplace() {
        dependencies.locationManager.getCurrentLocation { [weak self] latitude, longitude in
            guard let strongSelf = self else { return }
            UseCaseWrapper(with: strongSelf.useCaseProvider.getMarketplaceUseCase(input: GetMarketplaceWebViewConfigurationInput(latitude: latitude, longitude: longitude)), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] (result) in
                guard let self = self else {
                    return
                }
                self.dependencies.navigatorProvider.privateHomeNavigator.goToWebView(with: result.configuration, linkHandler: nil, dependencies: self.dependencies, errorHandler: self.errorHandler, didCloseClosure: nil)
                }, onError: { _ in
                    //TODO Error
            })
        }
    }
    
    func didSelectInCarbonFootprint() {
        let tokenIdScenario = self.getCarbonFootprintTokenIdScenario()
        let tokenDataScenario = self.getGetCarbonFootprintDataScenario()
        let values: (tokenId: String?, tokenData: String?) = (nil, nil)
        let text = LoadingText(title: stringLoader.getString("generic_popup_loading"), subtitle: stringLoader.getString("loading_label_moment"))
        LoadingCreator.showGlobalLoading(loadingText: text, controller: self.viewController ?? UIViewController()) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.drawer?.setRightEdgePanGesture(enabled: false)
            MultiScenario(handledOn: strongSelf.useCaseHandler, initialValue: values)
                .addScenario(tokenIdScenario) { (updatedValues, output, _) in
                    updatedValues.tokenId = output.token?.idToken
                }
                .addScenario(tokenDataScenario) { (updatedValues, output, _) in
                    updatedValues.tokenData = output.token?.idToken
                }
                .asScenarioHandler()
                .onSuccess { [weak self] finalValues in
                    guard let tokenId = finalValues.tokenId,
                          let tokenData = finalValues.tokenData else {
                              self?.drawer?.setRightEdgePanGesture(enabled: true)
                              self?.showErrorForCarbonFootprint(shouldHideLoading: true)
                              return
                          }
                    LoadingCreator.hideGlobalLoading {
                        self?.drawer?.setRightEdgePanGesture(enabled: true)
                        self?.handleCarbonFootprintNavigation(
                            tokenId: tokenId,
                            tokenData: tokenData
                        )
                    }
                }
                .onError { _ in
                    strongSelf.drawer?.setRightEdgePanGesture(enabled: true)
                    strongSelf.showErrorForCarbonFootprint(shouldHideLoading: true)
                }
        }
    }
    
    func didSelectImpruve() {
        dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.HelpImprove().page, extraParameters: [:])
        openOpinator(forRegularPage: .general, onError: { errorDescription in
            guard let view = self.viewController else {
                return
            }
            
            let acceptComponents = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
            Dialog.alert(title: nil, body: localized(errorDescription ?? "generic_error_internetConnection"), withAcceptComponent: acceptComponents, withCancelComponent: nil, source: view)
        })
    }
    
    func didSelectSearch() {
        if localAppConfig.isEnabledMagnifyingGlass {
            navigatorProvider.privateHomeNavigator.goToGlobalSearch()
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectMail() {
        if localAppConfig.isEnabledMailbox {
            self.navigatorProvider.inboxHomeNavigator.gotoInboxHome()
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectBalance() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }

    func didSelectBox(isCollapsed: Bool, id: String) {
        UseCaseWrapper(with: dependencies.useCaseProvider.getPGDataUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] result in
            guard 
                let strongSelf = self, 
                let userPref = result.userPref
            else { return }
            switch id {
            case "account":
                userPref.userPrefDTO.pgUserPrefDTO.accountsBox.isOpen = isCollapsed
            case "card":
                userPref.userPrefDTO.pgUserPrefDTO.cardsBox.isOpen = isCollapsed
            case "managedPortfolio":
                userPref.userPrefDTO.pgUserPrefDTO.portfolioManagedsBox.isOpen = isCollapsed
            case "notManagedPortfolio":
                userPref.userPrefDTO.pgUserPrefDTO.portfolioNotManagedsBox.isOpen = isCollapsed
            case "deposit":
                userPref.userPrefDTO.pgUserPrefDTO.depositsBox.isOpen = isCollapsed
            case "loan":
                userPref.userPrefDTO.pgUserPrefDTO.loansBox.isOpen = isCollapsed
            case "stockAccount":
                userPref.userPrefDTO.pgUserPrefDTO.stocksBox.isOpen = isCollapsed
            case "pension":
                userPref.userPrefDTO.pgUserPrefDTO.pensionssBox.isOpen = isCollapsed
            case "fund":
                userPref.userPrefDTO.pgUserPrefDTO.fundssBox.isOpen = isCollapsed
            case "insuranceSaving":
                userPref.userPrefDTO.pgUserPrefDTO.insuranceSavingsBox.isOpen = isCollapsed
            case "insuranceProtection":
                userPref.userPrefDTO.pgUserPrefDTO.insuranceProtectionsBox.isOpen = isCollapsed
            default:
                break
            }
            
            UseCaseWrapper(with: strongSelf.dependencies.useCaseProvider.getUpdatePGUserPrefUseCase(input: UpdatePGUserPrefUseCaseInput(userPref: userPref)), useCaseHandler: strongSelf.dependencies.useCaseHandler, errorHandler: strongSelf.errorHandler)
        })
    }
    
    func didSelectTimeLine() {
        let timeLine = TimeLine.load()
        self.viewController?.navigationController?.pushViewController(timeLine, animated: true)
    }
    
    func didSelectAction(_ action: Any, _ entity: AllOperatives, _ offers: [PullOfferLocation: OfferEntity]?) {
        switch entity {
        case .cardsActions:
            guard let action = action as? CardOperativeActionType else { return }
            didSelectCardsOperative(action, offers)
        case .accountActions:
            guard let action = action as? AccountOperativeActionType else { return }
            didSelectAccountOperative(action, offers)
        case .stocksActions:
            guard let action = action as? StocksActionType else { return }
            didSelectStocksOperative(action)
        case .loanActions:
            guard let action = action as? LoanActionType else { return }
            didSelectLoanOperative(action, offers)
        case .pensionActions:
            guard let action = action as? PensionActionType else { return }
            didSelectPensionOperative(action)
        case .fundActions:
            guard let action = action as? FundActionType else { return }
            didSelectFundOperative(action, offers)
        case .insuranceActions:
            guard let action = action as? InsuranceActionType else { return }
            didSelectInsuranceOperative(action)
        case .insuranceProtectionActions:
            guard let action = action as? InsuranceProtectionActionType else { return }
            didSelectInsuranceProtectionOperative(action)
        case .otherActions:
            guard let action = action as? OtherActionType else { return }
            didSelectOtherOperative(action, offers)
        }
    }
    
    func didSelectCardsOperative(_ operative: CardOperativeActionType, _ offers: [PullOfferLocation: OfferEntity]?) {
        guard checkIsOperativeAvailable(operative) else {
            return
        }
        switch operative {
        case .onCard:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.turnOnCard)
        case .offCard:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.turnOffCard)
        case .instantCash:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.directMoney)
        case .pin:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.pinQuery)
        case .cvv:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.cvvQuery)
        case .delayPayment:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.payLater)
        case .withdrawMoneyWithCode:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.withdrawMoneyWithCode)
        case .ces:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.cesSignUp)
        case .applePay:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.addToApplePay)
        case .changePaymentMethod:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.changeCardPayMethod)
        case .changeAlias:
            navigatorProvider.privateHomeNavigator.goToProductsCustomization()
        case .solidarityRounding:
            self.getCandidateOfferWithLocation(offers, OperatePullOffers.solidarityOperate) { offerId, location in
                self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        case .pdfExtract:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.cardPdfExtract)
        case .hireCard:
            self.goToPublicProducts(delegate: self, location: PullOfferLocation.OPERAR_CONTRATAR_TARJETAS)
        case .settingsAlerts:
            self.getCandidateOfferWithLocation(offers, OperatePullOffers.inboxOperate) { offerId, location in
                self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        case .payOff:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.payOff)
        case .subcriptions:
            navigatorProvider.privateHomeNavigator.gotoCardSubcriptions()
        case .modifyLimits:
            gotoCardLimitManagement()
        case .custom(let values):
            guard let location = values.location else {
                guard let modifier = self.dependenciesResolver.resolve(forOptionalType: OtherOperativesModifierProtocol.self) else {
                    Toast.show(localized("generic_alert_notAvailableOperation"))
                    return
                }
                modifier.performAction(values)
                return
            }
            self.getCandidateOfferWithLocation(offers, location) { [weak self] (offerId, location) in
                self?.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        default:
            navigatorProvider.privateHomeNavigator.present(selectedProduct: nil, productHome: .cards)
        }
    }
    
    func checkIsOperativeAvailable(_ operative: CardOperativeActionType) -> Bool {
        guard let getGPCardOperativeModifier: GetGPCardsOperativeOptionProtocol =
                self.dependenciesEngine.resolve(forOptionalType: GetGPCardsOperativeOptionProtocol.self),
              !getGPCardOperativeModifier.isOtherOperativeEnabled(operative) else {
            return true
        }
        Toast.show(localized("generic_alert_notAvailableOperation"))
        return false
    }

    func didSelectAccountOperative(_ operative: AccountOperativeActionType, _ offers: [PullOfferLocation: OfferEntity]?) {
        switch operative {
        case .transfer:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.transfer)
        case .internalTransfer:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.internalTransfer)
        case .favoriteTransfer:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.transfer)
        case .donation:
            self.getCandidateOfferWithLocation(offers, OperatePullOffers.donationsOperate) { offerId, location in
                self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        case .fxPay:
            self.getCandidateOfferWithLocation(offers, OperatePullOffers.fxPayOperate) { offerId, location in
                self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        case .payBill:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.billsAndTaxesPay)
        case .payTax:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.billsAndTaxesPay)
        case .changeDirectDebit:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.billsAndTaxesPay)
        case .cancelDirectDebit:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.billsAndTaxesPay)
        case .foreignExchange:
            self.getCandidateOfferWithLocation(offers, OperatePullOffers.foreignCurrencyOperate) { offerId, location in
                self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        case .contractAccounts:
            self.goToPublicProducts(delegate: self, location: PullOfferLocation.OPERAR_CONTRATAR_CUENTAS)
        case .changeAlias:
            navigatorProvider.privateHomeNavigator.goToProductsCustomization()
        case .settingsAlerts:
            self.getCandidateOfferWithLocation(offers, OperatePullOffers.inboxOperate) { offerId, location in
                self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        case .certificateOfOwnership:
            self.getCandidateOfferWithLocation(offers, OperatePullOffers.ownershipCertificateOperate) { offerId, location in
                self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        case .custom(let values):
            guard let location = values.location else {
                guard let modifier = self.dependenciesResolver.resolve(forOptionalType: OtherOperativesModifierProtocol.self) else {
                    Toast.show(localized("generic_alert_notAvailableOperation"))
                    return
                }
                modifier.performAction(values)
                return
            }
            self.getCandidateOfferWithLocation(offers, location) { [weak self] (offerId, location) in
                self?.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        case .transferOfContracts:
            self.getCandidateOfferWithLocation(offers, OperatePullOffers.transferOfContractsOperate) { offerId, location in
                self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        }
    }
    
    func didSelectStocksOperative(_ operative: StocksActionType) {
        navigatorProvider.privateHomeNavigator.present(selectedProduct: nil, productHome: .stocks)
    }
    
    func didSelectLoanOperative(_ operative: LoanActionType, _ offers: [PullOfferLocation: OfferEntity]?) {
        switch operative {
        case .configureAlerts:
            self.getCandidateOfferWithLocation(offers, OperatePullOffers.inboxOperate) { offerId, location in
                self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        case .changeAccount, .partialAmortization:
            navigatorProvider.privateHomeNavigator.present(selectedProduct: nil, productHome: .loans)
        case .custom(let values):
            guard let location = values.location else {
                guard let modifier = self.dependenciesResolver.resolve(forOptionalType: OtherOperativesModifierProtocol.self) else {
                    Toast.show(localized("generic_alert_notAvailableOperation"))
                    return
                }
                modifier.performAction(values)
                return
            }
            self.getCandidateOfferWithLocation(offers, location) { [weak self] (offerId, location) in
                self?.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        }
    }
    
    func didSelectPensionOperative(_ operative: PensionActionType) {
        switch operative {
        case .extraordinaryContribution:
            dependencies.deepLinkManager.registerDeepLink(DeepLink.extraordinaryContribution)
        default:
            navigatorProvider.privateHomeNavigator.present(selectedProduct: nil, productHome: .pensions)
        }
    }
    
    func didSelectFundOperative(_ operative: FundActionType, _ offers: [PullOfferLocation: OfferEntity]?) {
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesEngine.resolve(for: AppConfigRepositoryProtocol.self)
        
        switch operative {
        case .subscription:
            guard let nativeMode = appConfigRepository.getBool(DomainConstant.appConfigFundOperationsSubcriptionNativeMode) else { return }
            if nativeMode {
                dependencies.deepLinkManager.registerDeepLink(DeepLink.fundSuscription)
            } else {
                self.getCandidateOfferWithLocation(offers, OperatePullOffers.suscriptionFundOperate) { offerId, location in
                    self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
                }
            }
        case .custom(let values):
            guard let location = values.location else {
                Toast.show(localized("generic_alert_notAvailableOperation"))
                return
            }
            self.getCandidateOfferWithLocation(offers, location) { [weak self] (offerId, location) in
                self?.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }       
        }
    }
    
    func didSelectInsuranceOperative(_ operative: InsuranceActionType) {
        navigatorProvider.privateHomeNavigator.present(selectedProduct: nil, productHome: .insuranceSavings)
    }
    
    func didSelectInsuranceProtectionOperative(_ operative: InsuranceProtectionActionType) {
        switch operative {
        case .managePolicy:
            navigatorProvider.privateHomeNavigator.present(selectedProduct: nil, productHome: .insuranceProtection)
        case .custom(let values):
            guard let modifier = self.dependenciesResolver.resolve(forOptionalType: OtherOperativesModifierProtocol.self) else {
                Toast.show(localized("generic_alert_notAvailableOperation"))
                return
            }
            modifier.performAction(values)
        }
    }

    func didSelectOtherOperative(_ operative: OtherActionType, _ offers: [PullOfferLocation: OfferEntity]?) {
        switch operative {
        case .officeAppointment:
            self.getCandidateOfferWithLocation(offers, OperatePullOffers.officeAppointmentOperate) { offerId, location in
                self.dependencies.deepLinkManager.registerDeepLink(DeepLink.offerLink(identifier: offerId, location: location))
            }
        case .custom(let values):
            guard let modifier = self.dependenciesResolver.resolve(forOptionalType: OtherOperativesModifierProtocol.self) else {
                Toast.show(localized("generic_alert_notAvailableOperation"))
                return
            }
            modifier.performAction(values)
        }
    }
}

private extension GlobalPositionModuleCoordinatorNavigator {
    func goToPublicProducts(_ offer: OfferEntity?, location: PullOfferLocation?) {
        goToPublicProducts(delegate: self, location: location)
    }
    
    func getCandidateOffer(_ location: PullOfferLocation, _ stringTagLocation: String, completion: @escaping (OfferEntity?) -> Void) {
        let useCase = useCaseProvider.getCandidatesUseCase(input: PullOfferCandidatesUseCaseInput(locations: [location]))
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            let pullOffer = result.candidates.first { $0.key == stringTagLocation }
            guard let offer = pullOffer?.value else {
                completion(nil)
                return
            }
            completion(OfferEntity(offer.dto, location: location))
        })
    }
    
    func getCandidateOfferWithLocation(_ offers: [PullOfferLocation: OfferEntity]?, _ stringLocation: String, completion: @escaping (String, PullOfferLocation) -> Void) {
        guard let offers = offers else { return }
        let pullOffer = offers.first { $0.key.stringTag == stringLocation }
        guard let offer = pullOffer?.value, let offerId = offer.id, let location = offer.location else { return }
        completion(offerId, location)
    }
    
    func handleCarbonFootprintNavigation(tokenId: String,
                                         tokenData: String) {
        let useCase = self.useCaseProvider.getCarbonFootprintWebViewConfigurationUseCase(
            tokenId: tokenId,
            tokenData: tokenData
        )
        let input = GetCarbonFootprintWebViewConfigurationInput(tokenId: tokenId,
                                                                tokenData: tokenData)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] output in
                guard let self = self else { return }
                self.dependencies.navigatorProvider.privateHomeNavigator.goToWebView(
                    with: output.configuration,
                    linkHandler: nil,
                    dependencies: self.dependencies,
                    errorHandler: self.errorHandler,
                    didCloseClosure: nil
                )
            }
            .onError { _ in
                self.showErrorForCarbonFootprint(shouldHideLoading: false)
            }
    }
    
    func evaluateSanKey() {
        guard let modifier = dependencies.dependenciesEngine.resolve(forOptionalType: SantanderKeyFirstLoginModifierProtocol.self) else {
            self.loginMessages.update(state: .santanderKey, withValue: true)
            return
        }
        modifier.evaluateSanKey { [weak self] bool in
            self?.loginMessages.update(state: .santanderKey, withValue: bool)
        }
    }
}

// MARK: - Icono adaptativo app
private extension GlobalPositionModuleCoordinatorNavigator {
    func checkChangeAppIcon() {
        UseCaseWrapper(with: self.dependencies.useCaseProvider.getChangeAppIconUseCase(),
                       useCaseHandler: self.dependencies.useCaseHandler,
                       errorHandler: self.errorHandler,
                       onSuccess: { [weak self] result in
                        guard let strongSelf = self else { return }
                        switch result.status {
                        case .valid:
                            guard let validCampaign = result.appIconEntity, Assets.image(named: validCampaign.iconName) != nil else {
                                strongSelf.loginMessages.stateHandled(state: .alternativeIcon, value: false)
                                return
                            }
                            strongSelf.showChangeAppIconDialog(validCampaign)
                        case .notValid:
                            strongSelf.loginMessages.stateHandled(state: .alternativeIcon, value: false)
                            return
                        case .finishedCampaign:
                            strongSelf.checkChangeToOriginalIcon {
                                strongSelf.loginMessages.stateHandled(state: .alternativeIcon, value: false)
                            }
                        }
        }, onError: { _ in
            self.loginMessages.stateHandled(state: .alternativeIcon, value: false)
        })
    }
    
    func showChangeAppIconDialog(_ validCampaign: AppIconEntity) {
        guard let viewController = viewController else { return }
        let dialog = DialogAppIcon(iconName: validCampaign.iconName, action: { [weak self] (confirmed, checkButton) in
            if confirmed {
                self?.changeIcon(validCampaign.iconName) {
                    self?.loginMessages.saveValidCampaign(validCampaign)
                }
            } else if checkButton {
                self?.loginMessages.saveValidCampaign(validCampaign)
            } else {
                self?.loginMessages.stateHandled(state: .alternativeIcon, value: false)
            }
        })
        dialog.show(in: viewController)
    }
    
    func checkChangeToOriginalIcon(_ completion: @escaping (() -> Void)) {
        guard let currentIcon = UIApplication.shared.alternateIconName, !currentIcon.isEmpty else {
            completion()
            return
        }
        changeIcon(nil) {
            completion()
        }
    }
    
    func changeIcon(_ iconName: String?, completion: @escaping (() -> Void)) {
        guard #available(iOS 10.3, *), UIApplication.shared.supportsAlternateIcons else {
            completion()
            return
        }
        UIApplication.shared.setAlternateIconName(iconName, completionHandler: { _ in
            completion()
        })
    }
    
    func showErrorForCarbonFootprint(shouldHideLoading: Bool) {
        guard shouldHideLoading else {
            self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
            return
        }
        LoadingCreator.hideGlobalLoading {
            self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
        }
    }
}

extension GlobalPositionModuleCoordinatorNavigator: TimeLineDelegate {
    func onTimeLineCTATap(from viewController: TimeLineDetailViewController, with action: CTAAction) { }
    func mask(displayNumber: String, completion: @escaping (_ displayNumberMasked: String) -> Void) { }
}

extension GlobalPositionModuleCoordinatorNavigator: GlobalPositionModuleCoordinatorDelegate {
    func didSelectFavouriteContact(_ contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate) {
        self.navigatorProvider.privateHomeNavigator.didSelectContact(contact, launcher: launcher, delegate: delegate)
    }
    
    func didTapInHistoricSendMoney() {
        navigatorProvider.privateHomeNavigator.goToHistoricSendMoney()
    }
    
    func didSelectFutureBill(_ bill: AccountFutureBillRepresentable, in bills: [AccountFutureBillRepresentable], for entity: AccountEntity) {
        navigatorProvider.privateHomeNavigator.goToFutureBill(bill, in: bills, for: entity)
    }
    
    func didSelectOffer(_ offer: OfferRepresentable?) {
        guard let offer = offer else { return }
        executeOffer(offer)
    }
    
    func openAppStore() {
        guard let appStoreUsecase = self.dependenciesResolver.resolve(forOptionalType: AppStoreInformationUseCase.self) else { return }
        Scenario(useCase: appStoreUsecase).execute(on: self.useCaseHandler).onSuccess { [weak self] info in
            self?.storeProductViewControllerDelegate.openAppStore(id: info.storeId)
        }
    }
    
    func goToWebView(configuration: WebViewConfiguration) {
        self.dependencies.navigatorProvider.privateHomeNavigator.goToWebView(with: configuration, linkHandler: nil, dependencies: self.dependencies, errorHandler: self.errorHandler, didCloseClosure: nil)
    }
}

extension GlobalPositionModuleCoordinatorNavigator: PublicProductsLauncher, PublicProductsLauncherDelegate {
    var offerPresenter: PullOfferActionsPresenter { self }
}

extension GlobalPositionModuleCoordinatorNavigator: LoanSimulatorOfferDelegate {
    func didSelect(offer: OfferEntity, in location: PullOfferLocation) {
        return didSelectOffer(offer: offer, in: location)
    }
}

extension GlobalPositionModuleCoordinatorNavigator: CardActivationLauncher {
    var origin: OperativeLaunchedFrom {
        return .pg
    }
    
    func didActivateCard(_ card: Any?) {
        guard let cardEntity = card as? CardEntity else { return }
        guard let cardBoardingModifier = dependenciesResolver.resolve(forOptionalType: CardBoardingModifierProtocol.self),
              cardBoardingModifier.alwaysActivateCardOnCardboarding() else {
            if cardEntity.isPrepaidCard {
                let card = CardFactory.getCard(cardEntity)
                activateCard(card, launchedFrom: origin, delegate: self)
            } else {
                self.performCardBoardingActivation(cardEntity)
            }
            return
        }
        self.performCardBoardingActivation(cardEntity)
    }
    
    private func performCardBoardingActivation(_ cardEntity: CardEntity) {
        self.dependenciesEngine.register(for: CardsHomeModuleCoordinatorDelegate.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        self.dependenciesEngine.register(for: CardBoardingCoordinatorDelegate.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        self.goToCardBoardingActivation(card: cardEntity)
    }
}

extension GlobalPositionModuleCoordinatorNavigator: CardOnOffOperativeLauncher {
    func didTurnOnCard(_ card: Any?) {
        guard let cardEntity = card as? CardEntity else { return }
        self.goToCardOnOff(card: cardEntity, option: .turnOn)
    }
    
    func goToCardOnOff(card: CardEntity?, option: CardBlockType) {
        self.goToCardOnOff(card: card, option: option, handler: self)
    }
}

// MARK: - FIRST LOGIN

extension GlobalPositionModuleCoordinatorNavigator: LoginMessagesDelegate {
    var useCaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        return dependencies.useCaseHandler
    }
    
    var useCaseErrorHandler: UseCaseErrorHandler {
        return errorHandler
    }
    
    func handle(state: LoginMessagesState) {
        guard viewController is PGViewProtocol else { return }
        self.loginMessagesCurrentState = state
        switch state {
        case .updateDeviceToken:
            launchStart()
        case .tutorialBeforeOnboarding:
            showTutorialBeforeOnboarding()
        case .onboarding:
            launchOnboarding()
        case .signatureActivation:
            showSignatureActivationDialog()
        case .tutorial:
            showTutorial()
        case .santanderKey:
            self.evaluateSanKey()
        case .alternativeIcon:
            checkChangeAppIcon()
        case .floatingBanner:
            showFloatingBanner()
        case .notificationsPermission:
            requestPushNotifications()
        case .biometryAuthActivation:
            showBiometryAuthDialogIfAvailable()
        case .globalLocationPermission:
            askGlobalLocationIfNeeded()
        case .whatsNew:
            configureWhatsNew()
        case .updateUserPassword:
            gotoChangePassword()
        case .thirdLevelRecovery:
            showThirdLevelRecovery()
        case .finished:
            break
        }
    }
    
    private func launchStart() {
        notificationPermissionsManager?.checkAccess(nil)
        loginMessages.update(state: .updateDeviceToken, withValue: true)
        loginMessages.resume()
    }
    
    private func launchOnboarding() {
        guard let navigationController = onboardingCoordinator.navigationController as? NavigationController,
              let globalPositionVC = navigationController.viewControllers.first,
              globalPositionVC is PGViewProtocol else { return }
        onboardingCoordinator.start()
        onboardingCoordinator.onFinish = { [weak self] in
            let termination: OnboardingTermination? = self?.onboardingCoordinator.dataBinding.get()
            if let gpOption = termination?.gpOption {
                self?.gpChanged(globalPositionOption: GlobalPositionOption(rawValue: gpOption.value()) ?? .classic)
            }
            if let type = termination?.type {
                switch type {
                case .cancelOnboarding(let deactivate):
                    self?.cancelOnboarding(cancelEnabled: deactivate, completion: { })
                case .digitalProfile:
                    self?.finishToDigitalProfile()
                case .onboardingFinished:
                    self?.finishOnboarding()
                }
            }
        }
    }
    
    private func showTutorialBeforeOnboarding() {
        guard let offer: Offer = loginMessages.getData(state: .tutorialBeforeOnboarding), let action = offer.action else {
            loginMessages.update(state: .tutorialBeforeOnboarding, withValue: false)
            loginMessages.resume()
            return
        }
        loginMessages.update(state: .tutorialBeforeOnboarding, withValue: true)
        executeOffer(action: action, offerId: offer.id, location: PullOfferLocation.TUTORIAL)
    }
    
    private func showSignatureActivationDialog() {
        guard let viewController = viewController else { return }
        let later = DialogButtonComponents(titled: localized("loginActivationSignature_alert_button_moreLater"),
                                           does: { [weak self] in
                                            self?.loginMessages.stateHandled(state: .signatureActivation, value: false)
        })
        
        let now = DialogButtonComponents(titled: localized("loginActivationSignature_alert_button_signingChange"),
                                         does: { [weak self] in
                                            self?.loginMessages.update(state: .signatureActivation, withValue: true)
                                            self?.goToActivateSignature()
        })
        
        Dialog.alertLeftALign(title: stringLoader.getString("loginActivationSignature_alert_title_welcome"),
                              body: stringLoader.getString("loginActivationSignature_alert_welcome"),
                              withAcceptComponent: now,
                              withCancelComponent: later,
                              source: viewController)
    }
    
    private func showTutorial() {
        guard let tutorialOffer: Offer = loginMessages.getData(state: .tutorial), let action = tutorialOffer.action else {
            loginMessages.update(state: .tutorial, withValue: false)
            loginMessages.resume()
            return
        }
        loginMessages.update(state: .tutorial, withValue: true)
        executeOffer(action: action, offerId: tutorialOffer.id, location: PullOfferLocation.TUTORIAL)
    }
    
    private func showFloatingBanner() {
        guard let offer: Offer = self.loginMessages.getData(state: .floatingBanner) else {
            self.loginMessages.stateHandled(state: .floatingBanner, value: true)
            return
        }
        switch offer.action {
        case is SmallBottomBannerAction:
            showSmallBottomBanner(offer)
        case is BubbleBannerAction:
            showBubbleBanner(offer)
        case is FullScreenBannerAction:
            showFullScreenBanner(offer)
        default:
            break
        }
    }
    
    func showFullScreenBanner(_ offer: Offer) {
        guard let offerAction = offer.action as? FullScreenBannerAction  else {
            self.loginMessages.stateHandled(state: .floatingBanner, value: true)
            return
        }
        self.executeOffer(action: offerAction, offerId: offer.id, location: PullOfferLocation.PG_FLOATING_BANNER)
        self.loginMessages.stateHandled(state: .floatingBanner, value: true)
    }
    
    func showSmallBottomBanner(_ offer: Offer) {
        guard let offerAction = offer.action as? SmallBottomBannerAction  else {
            self.loginMessages.stateHandled(state: .floatingBanner, value: true)
            return
        }
        let floatingBanner = FloatingBannerView()
        floatingBanner.setImageUrl(offerAction.banner.url)
        floatingBanner.setAutomaticallyCloseInterval(offerAction.closeTime)
        floatingBanner.setTransparentClosure(offer.transparentClosure)
        floatingBanner.delegate = self
        let pgViewController = (drawer?.currentRootViewController as? UINavigationController)?
            .viewControllers.first(where: {$0 is PGViewProtocol})
        pgViewController?.view.addSubview(floatingBanner)
        pgViewController?.view.bringSubviewToFront(floatingBanner)
        if let action = offerAction.action {
            floatingBanner.addAction({[weak self] in
                self?.executeOffer(action: action, offerId: offer.id, location: PullOfferLocation.PG_FLOATING_BANNER)
            })
        }
        
        floatingBanner.startAnimation()
        self.loginMessages.stateHandled(state: .floatingBanner, value: true)
    }
    
    func showBubbleBanner(_ offer: Offer) {
        defer {
            self.loginMessages.stateHandled(state: .floatingBanner, value: true)
        }
        guard let offerAction = offer.action as? BubbleBannerAction  else {
            return
        }
        let bubbleBanner = BubbleBannerView()
        bubbleBanner.setImageUrl(offerAction.banner.url)
        bubbleBanner.setAutomaticallyCloseInterval(offerAction.closeTime)
        bubbleBanner.delegate = self
        if let viewController = viewController as? PGSmartViewController {
            bubbleBanner.bottomRelativeView = viewController.optionsBarView
        }
        self.viewController?.view.addSubview(bubbleBanner)
        self.viewController?.view.bringSubviewToFront(bubbleBanner)
        if let action = offerAction.action {
            bubbleBanner.addAction({[weak self] in
                self?.executeOffer(action: action, offerId: offer.id, location: PullOfferLocation.PG_FLOATING_BANNER)
            })
        }
        bubbleBanner.startAnimation()
        self.bubbleBanner = bubbleBanner
    }
    
    func requestPushNotifications() {
        safetyCurtainSafeguardEventWillBegin()
        notificationPermissionsManager?.requestAccess { [weak self] _ in
            self?.safetyCurtainSafeguardEventDidFinish()
            self?.loginMessages.stateHandled(state: .notificationsPermission, value: true)
        }
    }
    
    private func showBiometryAuthDialogIfAvailable() {
        UseCaseWrapper(with: dependencies.useCaseProvider.getOnboardingUseCase(dependencies: dependencies),
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: errorHandler,
                       onSuccess: { [weak self] result in
                        guard result.loginType != .U else {
                            self?.loginMessages.stateHandled(state: .biometryAuthActivation, value: true)
                            return
                        }
                        self?.showBiometryAuthDialog()
        })
    }
    
    private func showBiometryAuthDialog() {
        let titleKey: String
        let bodyKey: String
        switch localAuthentication.biometryTypeAvailable {
        case .faceId:
            titleKey = "loginTouchId_alert_title_faceIdActivate"
            bodyKey = "faceId_alert_forActivateFace"
        case .touchId:
            titleKey = "loginTouchId_alert_title_touchId"
            bodyKey = "loginTouchId_alert_touchId"
        case .none: return
        case .error: return
        }
        let cancel = DialogButtonComponents(titled: stringLoader.getString("generic_button_cancel")) { [weak self] in
            self?.loginMessages.stateHandled(state: .biometryAuthActivation, value: true)
        }
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept")) { [weak self] in
            self?.startRegisterForBiometryAuthProcess {
                self?.loginMessages.stateHandled(state: .biometryAuthActivation, value: true)
            }
        }
        guard let view = self.viewController else { return }
        Dialog.alert(title: stringLoader.getString(titleKey), body: stringLoader.getString(bodyKey),
                     withAcceptComponent: accept,
                     withCancelComponent: cancel,
                     source: view)
    }
    
    private func askGlobalLocationIfNeeded() {
        if dependencies.locationManager.askGlobalLocation() {
            guard let view = self.viewController else { return }
            let title: LocalizedStylableText = dependencies.stringLoader.getString("permissionsAlert_title_publicLocation")
            let body: LocalizedStylableText = dependencies.stringLoader.getString("permissionsAlert_text_publicLocation")
            let okCompletion: () -> Void = { [weak self] in
                self?.dependencies.locationManager.askAuthorizationIfNeeded { [weak self] in
                    self?.dependencies.locationManager.askedGlobalLocation()
                    self?.loginMessages.stateHandled(state: .globalLocationPermission, value: true)
                }
            }
            let cancelCompletion: () -> Void = { [weak self] in
                self?.dependencies.locationManager.askedGlobalLocation()
                self?.loginMessages.stateHandled(state: .globalLocationPermission, value: true)
            }
            let acceptComponents: DialogButtonComponents = DialogButtonComponents(titled: localized("generic_button_continue"), does: okCompletion)
            let cancelComponents: DialogButtonComponents = DialogButtonComponents(titled: localized("generic_button_cancel"), does: cancelCompletion)
            Dialog.alert(title: title, body: body, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: view)
            dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.LocationPermissions().page, extraParameters: [:])
        } else {
            self.loginMessages.stateHandled(state: .globalLocationPermission, value: true)
        }
    }
    
    func configureWhatsNew() {
        self.loginMessages.saveWhatsNewCounter()
    }
    
    private func gotoChangePassword() {
        ForcedPasswordUpdateProxy.shared.delegate = self
        self.goToChangePassword(handler: self)
    }
    
    func showThirdLevelRecovery() {
        (viewController as? PGViewProtocol)?.showThirdLevelRecoveryPopupIfNeeded(
            presented: { [weak self] in
                guard $0 else { return }
                self?.drawer?.closeSideMenu()
            },
            completion: { [weak self] in
                self?.loginMessages.stateHandled(state: .thirdLevelRecovery, value: false)
        })
    }
}

extension GlobalPositionModuleCoordinatorNavigator: FloatingBannerCloseDelegate {
    func didCloseFloatingBanner() {
        self.loginMessages.resume()
    }
}

extension GlobalPositionModuleCoordinatorNavigator: CardBoardingActivationLauncher {
    
    var cardExternalDependencies: CardExternalDependenciesResolver {
        return navigatorProvider.cardExternalDependenciesResolver
    }
    
    func goToCardBoardingActivation(card: CardEntity) {
        
        guard let cardBoardingActionModifier = self.dependenciesResolver.resolve(forOptionalType: CardBoardingActionModifierProtocol.self) else {
            self.goToCardBoardingActivation(card: card, handler: self)
            return
        }
        cardBoardingActionModifier.didSelectAction(.enable, card)
    }
}

extension GlobalPositionModuleCoordinatorNavigator: CardLimitManagementLauncher {
    func gotoCardLimitManagement() {
        goToCardLimitManagementOperative(card: nil, delegate: self)
    }
}

extension GlobalPositionModuleCoordinatorNavigator: ChangePasswordLauncher {}
extension GlobalPositionModuleCoordinatorNavigator: EnableOtpPushOperativeLauncher {}
extension GlobalPositionModuleCoordinatorNavigator: ActivateSignatureLauncher {
    var activateSignatureLauncherNavigator: OperativesNavigatorProtocol {
        self.navigator
    }
    
    func showError(keyDesc: String?) {
        self.showAlertError(keyTitle: nil, keyDesc: keyDesc, completion: nil)
    }
}

extension GlobalPositionModuleCoordinatorNavigator: OnboardingDelegate {
    func cancelOnboarding(cancelEnabled: Bool, completion: @escaping () -> Void) {
        guard cancelEnabled else {
            loginMessages.update(state: .onboarding, withValue: cancelEnabled, completion: completion)
            return
        }
        loginMessages.disableOnboarding(completion: completion)
    }
    
    var currentGlobalPosition: GlobalPositionOption? {
        set {
            currentGP = newValue
        }
        get {
            return currentGP
        }
    }
    
    var isGlobalPositionChanged: Bool? {
        set {
            isGPChanged = newValue
        }
        get {
            return isGPChanged
        }
    }
    
    func finishOnboarding() {
        loginMessages.finishOnboarding()
    }
    
    func finishToDigitalProfile() {
        self.navigatorProvider.privateHomeNavigator.goToDigitalProfile()
    }
}

extension GlobalPositionModuleCoordinatorNavigator: NewFavouriteLauncher, CreateUsualTransferOperativeLauncher {}
extension GlobalPositionModuleCoordinatorNavigator: SafetyCurtainDoorman {}

extension GlobalPositionModuleCoordinatorNavigator {
    private func startRegisterForBiometryAuthProcess(completion: @escaping () -> Void) {
        guard let view = self.viewController else { return }
        func showBiometryRegisterDialog(withKey key: String, code: String?) {
            var localizedKey: String
            switch localAuthentication.biometryTypeAvailable {
            case .faceId:
                localizedKey = "faceId"
            case .touchId:
                localizedKey = "touchId"
            case .none: return
            case .error: return
            }
            
            localizedKey += key
            
            let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept")) {
                completion()
            }
            var message = stringLoader.getString(localizedKey)
            if let code = code {
                message = LocalizedStylableText(text: message.text + " (\(code))", styles: nil)
            }
            Dialog.alert(title: nil, body: message,
                         withAcceptComponent: accept,
                         withCancelComponent: nil,
                         source: view)
        }
        
        let loadingText = LoadingText(title: localized("generic_popup_loading"), subtitle: localized("loading_label_moment"))
        LoadingCreator.showGlobalLoading(loadingText: loadingText, controller: view, completion: { [weak self] in
            self?.registerDevice(success: {
                LoadingCreator.hideGlobalLoading(completion: {
                    showBiometryRegisterDialog(withKey: "_alert_activeSuccess", code: nil)
                })
            }, failure: { error in
                LoadingCreator.hideGlobalLoading(completion: {
                    showBiometryRegisterDialog(withKey: "_alert_errorActivation", code: error?.getErrorDesc())
                })
            })
        })
    }
    
    private func registerDevice(success: @escaping () -> Void, failure: @escaping (StringErrorOutput?) -> Void) {
        UseCaseWrapper(with: useCaseProvider.registerDevice(input: RegisterDeviceInput(footPrint: UIDevice.current.getFootPrint(), deviceName: UIDevice.current.getDeviceName())), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (result) in
            
            guard let strongSelf = self else { return }
            
            UseCaseWrapper(with: strongSelf.useCaseProvider.setTouchIdLoginData(input: SetTouchIdLoginDataInput(deviceMagicPhrase: result.deviceMagicPhrase, touchIDLoginEnabled: result.touchIDLoginEnabled)), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { _ in
                strongSelf.localAuthentication.enableBiometric()
                success()
            }, onError: { error in
                failure(error)
            })
            }, onError: { error in
                failure(error)
        })
    }
    
    func gpChanged(globalPositionOption: GlobalPositionOption) {
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
        drawer?.setRoot(viewController: navigationController)
        pgCoordinator.navigationController = navigationController
        switch globalPositionOption {
        case .classic: pgCoordinator.start(.classic)
        case .simple: pgCoordinator.start(.simple)
        case .smart: pgCoordinator.start(.smart)
        }

        let presenter = dependenciesEngine.resolve(for: NavigatorProvider.self)
        let coordinator = presenter.presenterProvider.navigatorProvider
            .legacyExternalDependenciesResolver
            .privateMenuCoordinator()
        coordinator.start()
        guard let coordinatorNavigator = coordinator.navigationController else { return }
        drawer?.setSideMenu(viewController: coordinatorNavigator)
        dependenciesEngine.resolve(for: CoreSessionManager.self).sessionStarted(completion: nil)
    }
}

extension GlobalPositionModuleCoordinatorNavigator {
    func gotoCardTransactionDetail(transactionEntity: CardTransactionEntity, in transactionList: [CardTransactionWithCardEntity], cardEntity: CardEntity) {
        navigatorProvider.privateHomeNavigator.showCardTransaction(transactionEntity, in: transactionList, for: cardEntity)
    }
    
    func gotoAccountTransactionDetail(transactionEntity: AccountTransactionEntity, in transactionList: [AccountTransactionWithAccountEntity], accountEntity: AccountEntity) {        
         navigatorProvider.privateHomeNavigator.showAccountTransaction(transactionEntity, in: transactionList, for: accountEntity, associated: true)
     }

}

extension GlobalPositionModuleCoordinatorNavigator: DeepLinkLauncherPresentationProtocol {
    
    var viewProxy: ViewControllerProxy {
        return self.viewController ?? UIViewController()
    }
    
    func appOpenedFromDeeplink(deeplinkId: String) {
        
    }
}

extension GlobalPositionModuleCoordinatorNavigator: UniversalLauncherPresentationHandler {}

// MARK: Secure Device
private extension GlobalPositionModuleCoordinatorNavigator {
    
    // MARK: CarbonFootprint
    func getCarbonFootprintTokenIdScenario() -> Scenario<Void, GetCarbonFootprintIdUseCaseOkOutput, StringErrorOutput> {
        let useCase = self.useCaseProvider.getCarbonFootprintTokenIdUseCase()
        let scenario = Scenario(useCase: useCase)
        return scenario
    }
    
    func getGetCarbonFootprintDataScenario() -> Scenario<Void, GetCarbonFootprintDataUseCaseOkOutput, StringErrorOutput> {
        let useCase = self.useCaseProvider.getCarbonFootprintDataUseCase()
        let scenario = Scenario(useCase: useCase)
        return scenario
    }
}

extension GlobalPositionModuleCoordinatorNavigator: SantanderKeySecureDeviceViewDelegate {
    func didTapPlayVideo(offer: OfferEntity) {
        self.executeOffer(offer)
    }
}

extension GlobalPositionModuleCoordinatorNavigator: ForcedPasswordUpdatedNoticeable {
    func didUpdateForcedPassword() {
        self.loginMessages.update(state: .updateUserPassword, withValue: true)
    }
}
