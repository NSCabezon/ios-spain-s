import CoreFoundationLib
import Cards

typealias VoidNavigator = Void

public class NavigatorProvider {
    
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    let cardExternalDependenciesResolver: CardExternalDependenciesResolver
    let legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver
    private lazy var onboardinNavigator: OnboardingNavigatorProtocol = {
        return OnboardingNavigator(presenterProvider: presenterProvider,
                                         drawer: drawer,
                                         dependenciesEngine: dependenciesEngine)
    }()
    public init(drawer: BaseMenuViewController, presenterProvider: PresenterProvider, dependenciesEngine: DependenciesResolver & DependenciesInjector, legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver, cardExternalDependenciesResolver: CardExternalDependenciesResolver) {
        self.cardExternalDependenciesResolver = cardExternalDependenciesResolver
        self.legacyExternalDependenciesResolver = legacyExternalDependenciesResolver
        self.drawer = drawer
        self.presenterProvider = presenterProvider
        self.dependenciesEngine = dependenciesEngine
    }
    
    lazy var voidNavigator: VoidNavigator = {
        return VoidNavigator()
    }()
    
    private var coordinators: [ModuleCoordinatorNavigator] = []
    var sessionNavigator: SessionNavigator {
        return SessionNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine, legacyExternalDependenciesResolver: legacyExternalDependenciesResolver)
    }
    
    var appNavigator: AppNavigatorProtocol {
        return AppNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var splashNavigator: SplashNavigator {
        return SplashNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine, legacyExternalDependenciesResolver: legacyExternalDependenciesResolver)
    }
    
    var publicHomeNavigator: PublicHomeNavigator {
        return PublicHomeNavigatorImpl(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine, legacyExternalDependenciesResolver: legacyExternalDependenciesResolver)
    }
    
    var privateHomeNavigator: PrivateHomeNavigator & PrivateHomeNavigatorSideMenu & BaseWebViewNavigatable & PullOffersActionsNavigatorProtocol & BaseWebViewNavigatableLauncher & PrivateHomeNavigatorLauncher {
        return PrivateHomeNavigatorImpl(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine, legacyExternalDependenciesResolver: legacyExternalDependenciesResolver, cardExternalDependencies: cardExternalDependenciesResolver)
    }
    
    var productCollectionNavigator: ProductCollectionNavigatorProtocol {
        return ProductCollectionNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var operativesNavigator: OperativesNavigatorProtocol {
        return OperativesNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var transfersHomeNavigator: TransfersHomeNavigatorProtocol {
        return TransfersHomeNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
        
    var billAndTaxesFilterNavigator: BillAndTaxesFilterNavigatorProtocol {
        return BillAndTaxesFilterNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var baseWebViewNavigator: BaseWebViewNavigatorProtocol {
        return BaseWebViewNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var productHomeNavigator: ProductHomeNavigatorProtocol {
        return ProductHomeNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var productDetailNavigator: ProductDetailNavigatorProtocol {
        return ProductDetailNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var transactionSearchNavigator: TransactionsSearchNavigatorProtocol {
        return TransactionsSearchNavigation(drawer: drawer, presenterProvider: presenterProvider)
    }
    
    var loanProfileNavigator: OperativesNavigatorProtocol {
        return LoanProfileNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var fundProfileNavigator: OperativesNavigatorProtocol {
        return FundProfileNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var pensionProfileNavigator: OperativesNavigatorProtocol {
        return PensionProfileNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var stockProfileNavigator: StockProfileNavigatorProtocol {
        return StockProfileNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var ordersProfileNavigator: OperativesNavigatorProtocol {
        return OrdersProfileNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var quoteConfigurationItemsSelectionNavigator: QuoteConfigurationItemsSelectionNavigatorProtocol {
        return QuoteConfigurationItemsSelectionNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var contributionQuoteConfigurationNavigator: ContributionQuoteConfigurationNavigatorProtocol {
        return ContributionQuoteConfigurationNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var cardProfileNavigator: OperativesNavigatorProtocol {
        return CardProfileNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var accountProfileNavigator: AccountProfileNavigatorProtocol {
        return AccountProfileNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var transactionDetailNavigator: TransactionDetailNavigatorProtocol & PullOffersActionsNavigatorProtocol {
        return TransactionDetailNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }

    var cardTransactionDetailNavigator: OperativesNavigatorProtocol {
        return CardTransactionDetailNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var cardChangePaymentMethodNavigator: ChangePaymentMethodNavigatorProtocol {
        return ChangePaymentMethodNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var stockSearchNavigator: StockSearchNavigatorProtocol {
        return StockSearchNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var shareNavigator: ShareNavigatorProtocol {
        return ShareNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var personalManagerNavigator: PersonalManagerNavigatorProtocol & PullOffersActionsNavigatorProtocol {
        return PersonalManagerNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var personalAreaNavigator: PersonalAreaNavigatorProtocol & PullOffersActionsNavigatorProtocol {
        return PersonalAreaNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine, legacyExternalDependenciesResolver: legacyExternalDependenciesResolver)
    }
    
    var customerServiceNavigator: CustomerServiceNavigatorProtocol & PullOffersActionsNavigatorProtocol {
        return CustomerServiceNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var orderDetailNavigator: OrderDetailNavigatorProtocol {
        return OrderDetailNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var stockDetailNavigator: StockDetailNavigatorProtocol & PullOffersActionsNavigatorProtocol {
        return StockDetailNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var appStoreNavigator: AppStoreNavigatable {
        return AppStoreNavigator()
    }
    
    var applePayLauncherNavigator: ApplePayLauncherNavigatorProtocol {
        return ApplePayLauncherNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var applePayNavigator: ApplePayNavigatorProtocol {
        return ApplePayNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine)
    }
    
    var stocksAlertsConfigurationNavigator: StocksAlertsConfigurationNavigatorProtocol {
        return StocksAlertsConfigurationNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var sofiaNavigator: SOFIANavigatorProtocol {
        return SOFIANavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var operativeSummaryNavigator: OperativeSummaryNavigatorProtocol {
        return OperativeSummaryNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var withdrawMoneySummaryNavigator: WithdrawMoneySummaryNavigatorProtocol {
        return WithdrawMoneySummaryNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var defaultOperativeFinishedNavigator: StopOperativeProtocol {
        return DefaultOperativeFinishedNavigator()
    }
    
    var personalAreaFinishedNavigator: StopOperativeProtocol {
        return ActivateAndChangeSignatureOperativeFinishedNavigator(presenterProvider: presenterProvider)
    }
    
    var toHomeOperativeFinishNavigator: StopOperativeProtocol {
        return ToHomeOperativeFinishNavigator()
    }
    
    var toBillHomeOperativeFinishNavigator: StopOperativeProtocol {
        return BillOperativeFinishNavigator()
    }
    
    func toHomeTransferNavigator(type: OnePayTransferOperativeFinishType = .home) -> StopOperativeProtocol {
        switch type {
        case .pg:
            return BackToPgFinishedNavigator()
        case .home:
            return ToHomeTransferNavigator()
        }
    }
    
    var toRetirementPlanHomeNavigator: StopOperativeProtocol {
        return ToRetirementPlanHomeNavigator()
    }
    
    var toInvestmentFundsHomeNavigator: StopOperativeProtocol {
        return ToInvestmentFundsHomeNavigator()
    }
    
    var toCardsHomeNavigator: StopOperativeProtocol {
        return CardsHomeFinishNavigator()
    }
    
    var applePayFinishNavigator: StopOperativeProtocol {
        return AddToApplePayFinishNavigator()
    }
    
    var toLoansHomeNavigator: StopOperativeProtocol {
        return LoansOperativeFinishNavigator()
    }
    
    var stockTradeOperativeFinishedNavigator: StopOperativeProtocol {
        return StockTradeOperativeFinishedNavigator()
    }
    
    var cancelOrderOperativeFinishedNavigator: StopOperativeProtocol {
        return CancelOrderOperativeFinishedNavigator(presenterProvider: presenterProvider)
    }
    
    var changePasswordOperativeFinishedNavigator: StopOperativeProtocol {
        return ChangePasswordOperativeFinishedNavigator(presenterProvider: presenterProvider)
    }
    
    var withdrawHistoricalOperativeFinishedNavigator: StopOperativeProtocol {
        return WithdrawHistoricalOperativeFinishedNavigator()
    }
    
    var backToPgFinishedNavigator: StopOperativeProtocol {
        return BackToPgFinishedNavigator()
    }

    var withdrawMoneyNavigator: WithdrawMoneyNavigatorProtocol {
        return WithdrawMoneyNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var withdrawMoneyHistoricalNavigator: WithdrawMoneyHistoricalNavigatorProtocol {
        return WithdrawMoneyHistoricalNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var cvvQueryCardFinishedNavigator: StopOperativeProtocol {
        return CVVQueryCardViewOperativeFinishedNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var pinQueryCardViewOperativeFinishedNavigator: StopOperativeProtocol {
        return PINQueryCardViewOperativeFinishedNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: - Transfers
    
    var transferEmittedDetailNavigator: TransferDetailNavigatorProtocol {
        return TransferEmittedDetailNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var cancelTransferConfirmationNavigator: CancelTransferConfirmationNavigatorProtocol {
        return CancelTransferConfirmationNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var transferSearchableConfigurationSelectionNavigator: TransferSearchableConfigurationSelectionNavigatorProtocol & PullOffersActionsNavigatorProtocol {
        return TransferSearchableConfigurationSelectionNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: Mifid
    
    var defaultMifidLauncherNavigator: DefaultMifidLauncherNavigator {
        return DefaultMifidLauncherNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var appInfoNavigator: AppInfoNavigatorProtocol {
        return AppInfoNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: Tips
    
    var tipsNavigator: TipNavigatorProtocol {
        return TipNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var pullOfferBannerNavigator: PullOfferBannerNavigatorProtocol & PullOffersActionsNavigatorProtocol {
        return PullOfferBannerNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: - One pay
    
    var onePayTransferNavigator: OnePayTransferNavigatorProtocol & PullOffersActionsNavigatorProtocol {
        return OnePayTransferNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var noSepaNaviagator: NoSepaNavigatorProtocol {
        return NoSepaNaviagator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: - Usual Transfer Payee
    
    var usualTransferNavigator: UsualTransferNavigatorProtocol {
        return UsualTransferNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: - Scanner
    
    var scannerNavigator: BarcodeScannerNavigatorProtocol {
        return BarcodeScannerNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: - DeepLinks
    
    var deepLinkNavigator: DeepLinkNavigatorProtocol {
        return DeepLinkNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var cardPdfExtractNavigator: CardPfdStatementNavigator {
        return CardPfdStatementNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var accountSelectionNavigator: AccountSelectionNavigator {
        return AccountSelectionNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: - EasyPay
    
    var easyPayNavigator: EasyPayNavigatorProtocol {
        return EasyPayNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine)
    }
    
    // MARK: - Tab Container Navigator
    
    var tabContainerNavigator: TabContainerNavigatorProtocol {
        return TabContainerNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var pushMailBoxNavigator: PushMailBoxNavigator {
        return PushMailBoxNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var pushNotificationsNavigator: PushNotificationsNavigatorProtocol {
        return PushNotificationsNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: - Card Limit
    
    var cardLimitNavigator: CardLimitNavigatorProtocol {
        return CardLimitNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: - Logout
    
    var logoutNavigator: LogoutDialogNavigator {
        return LogoutDialogNavigatorImp(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: Landing Push
    
    var landingPushLauncherNavigator: LandingPushLauncherNavigator {
        return LandingPushLauncherNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var genericLandingPushLauncherNavigator: GenericLandingPushNavigator {
        return GenericLandingPushNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: - List dialog
    
    var listDialogNavigator: ListDialogNavigator {
        return ListDialogNavigatorImp(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: - OTPPush
    
    var otpPushInfoNavigator: OTPPushInfoNavigatorProtocol {
        return OTPPushInfoNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var otpPushOperativeFinishedNavigator: StopOperativeProtocol {
        return EnableOtpPushOperativeFinishedNavigator()
    }
    
    // MARK: OTP SCA
    
    var otpScaLoginNavigator: OtpScaLoginNavigator {
        return OtpScaLoginNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine, legacyExternalDependenciesResolver: legacyExternalDependenciesResolver)
    }
    
    var otpScaAccountNavigator: OtpScaAccountNavigatorProtocol {
        return OtpScaAccountNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    // MARK: Onboarding Navigator
    var onboardingNavigator: OnboardingNavigatorProtocol {
        return self.onboardinNavigator
    }
    
    var transferHomeNavigator: TransferHomeNavigator {
        return TransferHomeNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesResolver: dependenciesEngine)
    }

    var loanDetailNavigator: LoanDetailNavigator {
        return LoanDetailNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine, legacyExternalDependenciesResolver: legacyExternalDependenciesResolver)
    }
        
    var inboxHomeNavigator: InboxHomeNavigator {
        return InboxHomeNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine)
    }
    
    var menuHomeNavigator: MenuHomeNavigator {
        return MenuHomeNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine)
    }
    
    var billsHomeNavigator: BillsHomeNavigator {
        return BillsHomeNavigator(presenterProvider: presenterProvider, drawer: drawer)
    }
    
    var cardboardingNavigator: CardBoardingNavigatorProtocol {
        return CardBoardingNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine)
    }
    
    // MARK: Products
    var productsNavigator: ProductsNavigatorProtocol {
        return ProductsNavigator(presenterProvider: presenterProvider, drawer: drawer, dependenciesEngine: dependenciesEngine, legacyExternalDependenciesResolver: legacyExternalDependenciesResolver, cardExternalDependenciesResolver: cardExternalDependenciesResolver)
    }
}

// MARK: - Modules

extension NavigatorProvider {
    
    func getModuleCoordinator<Coordinator: ModuleCoordinatorNavigator>(type: Coordinator.Type) -> Coordinator {
        // Gets an already exist coordinator
        guard let coordinator = coordinators.first(where: { String(describing: type) == $0.coordinatorIdentifier }) as? Coordinator else {
            let coordinator = Coordinator(
                drawer: drawer,
                dependencies: presenterProvider.dependencies,
                navigator: operativesNavigator,
                stringLoader: presenterProvider.dependencies.stringLoader,
                dependenciesEngine: dependenciesEngine,
                coordinatorIdentifier: String(describing: type)
            )
            addCoordinator(coordinator)
            return coordinator
        }
        return coordinator
    }
    
    func addCoordinator(_ coordinator: ModuleCoordinatorNavigator) {
        defer { coordinators.append(coordinator) }
        guard let index = coordinators.firstIndex(where: { String(describing: $0) == coordinator.coordinatorIdentifier }) else { return }
        coordinators.remove(at: index)
    }
    
    func resetCoordinators() {
        self.coordinators = []
    }
}

extension NavigatorProvider: EasyPayNavigatorProviderProtocol {
    public var easyPayNavigatorDelegate: EasyPayNavigatorDelegate {
        return EasyPayNavigator(presenterProvider: presenterProvider,
                                drawer: drawer,
                                dependenciesEngine: dependenciesEngine)
    }
}

// MARK: - CorePushNotificationsService
public extension NavigatorProvider {
    
    func open(url: String) {
        privateHomeNavigator.open(url: url)
    }
    
    func openWebView(with url: String, title: String) {
        guard let presentationComponent = presenterProvider.dependencies
        else { return }
        let webViewConfig = PushNotificationsWebViewConfiguration(initialURL: url,
                                                                  bodyParameters: nil,
                                                                  closingURLs: [],
                                                                  webToolbarTitleKey: title,
                                                                  pdfToolbarTitleKey: nil,
                                                                  pdfSource: nil)
        appNavigator.goToWebView(with: webViewConfig,
                                 linkHandler: nil,
                                 dependencies: presentationComponent,
                                 errorHandler: nil,
                                 didCloseClosure: nil)
    }
    
    func openLandingPush(cardTransactionInfo: CardTransactionPush?, cardAlertInfo: CardAlertPush?) {
        guard
            landingPushLauncherNavigator.drawer.presentingViewController == nil,
            landingPushLauncherNavigator.drawer.presentedViewController == nil,
            landingPushLauncherNavigator.drawer.isSideMenuVisible == false
        else { return }
        landingPushLauncherNavigator.launchLandingPush(cardTransactionInfo: cardTransactionInfo, cardAlertInfo: cardAlertInfo)
    }
    
    func openGenericLandingPush(accountTransactionInfo: AccountLandingPushDataBridge) {
        guard landingPushLauncherNavigator.drawer.presentingViewController == nil,
              landingPushLauncherNavigator.drawer.presentedViewController == nil,
              landingPushLauncherNavigator.drawer.isSideMenuVisible == false,
              let oldInfo = AccountLandingPushData(bridgedInfo: accountTransactionInfo)
        else { return }
        landingPushLauncherNavigator.genericLaunchLandingPush(accountTransactionInfo: oldInfo)
    }
    
    func showDialog(title: String?, message: String?, completion: (() -> Void)?) {
        let accept = DialogButtonComponents(titled: localized("generic_button_accept"), does: completion)
        let cancel = DialogButtonComponents(titled: localized("generic_button_cancel"), does: nil)
        let titleMessage: LocalizedStylableText
        if let title = title, title.isNotEmpty {
            titleMessage = LocalizedStylableText(text: title, styles: nil)
        } else {
            titleMessage = localized("notificationMailbox_label_santander")
        }
        let bodyMessage: LocalizedStylableText
        if let message = message, message.isNotEmpty {
            bodyMessage = LocalizedStylableText(text: message, styles: nil)
        } else {
            bodyMessage = .empty
        }
        appNavigator.showDialogOnDrawer(title: titleMessage, body: bodyMessage, acceptButton: accept, cancelButton: cancel)
    }
    
    func getOnboardingNavigator() -> OnboardingNavigatorProtocol {
        return self.onboardingNavigator
    }
}
