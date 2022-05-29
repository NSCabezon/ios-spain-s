import CoreFoundationLib
import Foundation
import WebKit
import UI
import WebViews

public class PresenterProvider {
    var navigatorProvider: NavigatorProvider!
    let sessionManager: CoreSessionManager
    var dependencies: PresentationComponent!
    let localAuthentication: LocalAuthenticationPermissionsManagerProtocol
    let appEventsNotifier: AppEventsNotifier
    let dependenciesEngine: DependenciesResolver & DependenciesInjector

    init(sessionManager: CoreSessionManager, localAuthentication: LocalAuthenticationPermissionsManagerProtocol, appEventsNotifier: AppEventsNotifier, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.sessionManager = sessionManager
        self.localAuthentication = localAuthentication
        self.appEventsNotifier = appEventsNotifier
        self.dependenciesEngine = dependenciesEngine
    }
    
    var splashPresenter: SplashPresenter {
        return SplashPresenter(localAuthentication: localAuthentication, stringLoader: dependencies.stringLoader, navigator: navigatorProvider.splashNavigator, dependencies: dependencies)
    }

    var environmentsSelectorPresenter: EnvironmentsSelectorPresenter {
        return EnvironmentsSelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.publicHomeNavigator)
    }

    var privateSideMenuPresenter: PrivateSideMenuPresenter {
        return PrivateSideMenuPresenter(dependencies: dependencies, navigator: navigatorProvider.privateHomeNavigator, sessionManager: sessionManager, localAuthentication: localAuthentication)
    }

    func myProductsSideMenuPresenter(privateMenuWrapper: PrivateMenuWrapper, offerDelegate: PrivateSideMenuOfferDelegate) -> PrivateSubmenuPresenter {
        let presenter = PrivateSubmenuPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.privateHomeNavigator)
        presenter.helper = MyProductsHelper(privateMenuWrapper: privateMenuWrapper, presenter: presenter, navigator: presenter.navigator, offerDelegate: offerDelegate)
        return presenter
    }
    
    func sofiaSideMenuPresenter(privateMenuWrapper: PrivateMenuWrapper, offerDelegate: PrivateSideMenuOfferDelegate) -> PrivateSubmenuPresenter {
        let presenter = PrivateSubmenuPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.privateHomeNavigator)
        presenter.helper = SofiaInvestmentsHelper(privateMenuWrapper: privateMenuWrapper, presenter: presenter, navigator: presenter.navigator, offerDelegate: offerDelegate)
        return presenter
    }
    
    var publicProductsPresenter: PublicProductsPresenter {
        let presenter = PublicProductsPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productCollectionNavigator)
        return presenter
    }
    
    func billsAndTaxesFilterPresenter(filter: BillAndTaxesFilterParameters, delegate: BillAndTaxesFilterDelegate) -> BillAndTaxesFilterPresenter {
        let presenter = BillAndTaxesFilterPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.billAndTaxesFilterNavigator)
        presenter.filterDelegate = delegate
        presenter.filter = filter
        
        return presenter
    }
    
    func accountSelectorPresenter(accounts: [Account]) -> AccountSelectionPresenter {
        return AccountSelectionPresenter(accounts: accounts, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.accountSelectionNavigator)
    }
    
    func otherServicesMenuPresenter(privateMenuWrapper: PrivateMenuWrapper,
                                    offerDelegate: PrivateSideMenuOfferDelegate,
                                    comingFeatures: Bool) -> PrivateSubmenuPresenter {
        let presenter = PrivateSubmenuPresenter(dependencies: dependencies,
                                                sessionManager: sessionManager,
                                                navigator: navigatorProvider.privateHomeNavigator)
        presenter.helper = OtherServicesHelper(privateMenuWrapper: privateMenuWrapper,
                                               presenter: presenter,
                                               navigator: presenter.navigator,
                                               offerDelegate: offerDelegate,
                                               comingFeatures: comingFeatures)
        return presenter
    }
    
    func world123MenuPresenter(privateMenuWrapper: PrivateMenuWrapper,
                                    offerDelegate: PrivateSideMenuOfferDelegate,
                                    comingFeatures: Bool) -> PrivateSubmenuPresenter {
        let presenter = PrivateSubmenuPresenter(dependencies: dependencies,
                                                sessionManager: sessionManager,
                                                navigator: navigatorProvider.privateHomeNavigator)
        presenter.helper = World123Helper(privateMenuWrapper: privateMenuWrapper,
                                               presenter: presenter,
                                               navigator: presenter.navigator,
                                               offerDelegate: offerDelegate,
                                               comingFeatures: comingFeatures)
        return presenter
    }
    
    func myServicesForYouSideMenuPresenter(offerDelegate: PrivateSideMenuOfferDelegate) -> PrivateSubmenuPresenter {
        let presenter = PrivateSubmenuPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.privateHomeNavigator)
        presenter.helper = SmartServicesHelper(presenter: presenter, navigator: presenter.navigator, offerDelegate: offerDelegate)
        
        return presenter
    }

    var productHomePresenter: ProductHomePresenter {
        return ProductHomePresenter(header: productHomeHeaderPresenter, detail: productHomeDetailPresenter, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.productHomeNavigator)
    }
    
    var productHomePresenterStocks: ProductHomePresenter {
        return ProductHomeStockPresenter(header: productHomeHeaderPresenter, detail: productHomeDetailPresenter, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.productHomeNavigator)
    }
    
    var productHomePresenterManagedRVStocks: ProductHomePresenter {
        return ProductHomeStockPresenter(header: productHomeHeaderPresenter, detail: productHomeDetailPresenter, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.productHomeNavigator, origin: StockAccountOrigin.rvManaged)
    }
    
    var productHomePresenterNotManagedRVStocks: ProductHomePresenter {
        return ProductHomeStockPresenter(header: productHomeHeaderPresenter, detail: productHomeDetailPresenter, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.productHomeNavigator, origin: StockAccountOrigin.rvNotManaged)
    }
    
    var productProfileTransactionPresenter: PortfolioProductHomePresenter {
        return PortfolioProductHomePresenter(header: productHomeHeaderPresenter, detail: productHomeDetailPresenter, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.productHomeNavigator)
    }
    
    var productImpositionHomePresenter: ImpositionsHomePresenter {
        return ImpositionsHomePresenter(header: productHomeHeaderPresenter, detail: productHomeDetailPresenter, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.productHomeNavigator)
    }
    
    var fakeGlobalPositionPresenter: FakePGpresenter {
        return FakePGpresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.privateHomeNavigator)
    }
    
    var productDetailPresenter: ProductDetailPresenter {
        return ProductDetailPresenter(productDetailHeader: productDetailHeaderPresenter, productDetailInfo: productDetailInfoPresenter, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.productDetailNavigator)
    }
    
    func transactionsSearchPresenter(parameterSetup: SearchParameterCapable, filterChangeDelegate: FilterChangeDelegate) -> TransactionsSearchPresenter {
        return TransactionsSearchPresenter(parametersProvider: parameterSetup, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.transactionSearchNavigator, filterChangeDelegate: filterChangeDelegate)
    }
    
    var transactionDetailContainerPresenter: TransactionDetailContainerPresenter {
        return TransactionDetailContainerPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.transactionDetailNavigator)
    }
    
    var stockSearchPresenter: StockSearchPresenter {
        return StockSearchPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.stockSearchNavigator)
    }
    
    func stockDetailPresenter(stock: Stock?, stockAccount: StockAccount?, stockQuote: StockQuote?, origin: StockDetailNavigationOrigin) -> StockDetailPresenter {
        return StockDetailPresenter(dependencies, sessionManager: sessionManager, navigator: navigatorProvider.stockDetailNavigator, stock: stock, stockAccount: stockAccount, stockQuote: stockQuote, origin: origin)
    }
    
    var applePayPresenter: ApplePayPresenter {
        return ApplePayPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.applePayNavigator)
    }
    
    var stocksAlertsConfigurationPresenter: StocksAlertsConfigurationPresenter {
        return StocksAlertsConfigurationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.stocksAlertsConfigurationNavigator)
    }
    
    var sofiaPresenter: SOFIAPresenter {
        return SOFIAPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.sofiaNavigator)
    }
    
    var sharePresenter: SharePresenter {
        return SharePresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.shareNavigator)
    }
        
    func orderDetailPresenter(with order: Order, stock: StockAccount) -> OrderDetailPresenter {
        return OrderDetailPresenter(order: order, stock: stock, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.orderDetailNavigator)
    }
    
    func variableIncomePresenter() -> VariableIncomePresenter {
        return VariableIncomePresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.privateHomeNavigator)
    }
    
    var cvvQueryOperativePresenter: CVVQueryCardPresenter {
        return CVVQueryCardPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    func paymentMethodSubtypeSelectorPresenter(delegate: SelectCardModifyPaymentFormDelegate, info: PaymentMethodSubtypeInfo) -> PaymentMethodSubtypeSelectorPresenter {
        return PaymentMethodSubtypeSelectorPresenter(delegate: delegate, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.cardChangePaymentMethodNavigator, info: info)
    }
    
    // MARK: - Operatives
    
    var operativeSignatureWithTokenPresenter: GenericSignaturePresenter<SignatureWithToken> {
        return operativeSignaturePresenter()
    }
    
    var lisboaOperativeSignatureWithTokenPresenter: LisboaSignaturePresenter<SignatureWithToken> {
        return lisboaOperativeSignaturePresenter()
    }
    
    var operativeSimpleSignaturePresenter: GenericSignaturePresenter<Signature> {
        return operativeSignaturePresenter()
    }
    
    private func operativeSignaturePresenter<S: SignatureParamater>() -> GenericSignaturePresenter<S> {
        return GenericSignaturePresenter<S>(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productHomeNavigator)
    }
    
    private func lisboaOperativeSignaturePresenter<S: SignatureParamater>() -> LisboaSignaturePresenter<S> {
        return LisboaSignaturePresenter<S>(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productHomeNavigator)
    }
    
    var operativeOtpPresenter: GenericOtpPresenter {
        return GenericOtpPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productHomeNavigator)
    }
    
    var secureDeviceOtpPresenter: SecureDeviceOtpPresenter {
        return SecureDeviceOtpPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productHomeNavigator)
    }
    
    var operativeSummaryPresenter: OperativeSummaryPresenter {
        let presenter = OperativeSummaryPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.operativeSummaryNavigator)
        presenter.sharePresenter = sharePresenter
        return presenter
    }
    
    var operativeFinishedDialogPresenter: OperativeFinishedDialogPresenter {
        return OperativeFinishedDialogPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    lazy var loanOperatives: LoanOperativesPresenterProvider = {
        return LoanOperativesPresenterProvider(navigatorProvider: navigatorProvider, sessionManager: sessionManager, dependencies: dependencies)
    }()
    
    lazy var fundOperatives: FundOperativesPresenterProvider = {
        return FundOperativesPresenterProvider(navigatorProvider: navigatorProvider, sessionManager: sessionManager, dependencies: dependencies)
    }()
    
    lazy var pensionOperatives: PensionOperativesPresenterProvider = {
        return PensionOperativesPresenterProvider(navigatorProvider: navigatorProvider, sessionManager: sessionManager, dependencies: dependencies)
    }()
    
    lazy var cardOperatives: CardOperativesPresenterProvider = {
        return CardOperativesPresenterProvider(navigatorProvider: navigatorProvider, sessionManager: sessionManager, dependencies: dependencies)
    }()
    
    lazy var accountOperatives: AccountOperativesPresenterProvider = {
        return AccountOperativesPresenterProvider(navigatorProvider: navigatorProvider, sessionManager: sessionManager, dependencies: dependencies)
    }()
 
    lazy var stockOperatives: StockOperativesPresenterProvider = {
        return StockOperativesPresenterProvider(navigatorProvider: navigatorProvider, sessionManager: sessionManager, dependencies: dependencies)
    }()
    
    lazy var personalAreaOperatives: PersonalAreaOperativesPresenterProvider = {
        return PersonalAreaOperativesPresenterProvider(navigatorProvider: navigatorProvider, sessionManager: sessionManager, dependencies: dependencies)
    }()
    
    lazy var mifid: MifidPresenterProvider = {
        return MifidPresenterProvider(navigatorProvider: navigatorProvider, sessionManager: sessionManager, dependencies: dependencies)
    }()
    
    lazy var billsAndTaxesOperatives: BillsAndTaxesOperativesPresenterProvider = {
        return BillsAndTaxesOperativesPresenterProvider(navigatorProvider: navigatorProvider, sessionManager: sessionManager, dependencies: dependencies)
    }()
    
    var pinQueryOperativePresenter: PINQueryCardPresenter {
        return PINQueryCardPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    func operativeProductSelectionPresenter<Profile: OperativeProductSelectionProfile>() -> OperativeProductSelectionPresenter<Profile> {
        return OperativeProductSelectionPresenter<Profile>(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    func cardPdfExtractPresenter(cards: [Card]) -> CardPfdStatementSelectionPresenter {
        return CardPfdStatementSelectionPresenter(cards: cards, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.cardPdfExtractNavigator)
    }
    
    // MARK: - Privates
    private var productHomeHeaderPresenter: ProductHomeHeaderPresenter {
        return ProductHomeHeaderPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productHomeNavigator)
    }

    private var productHomeDetailPresenter: ProductHomeTransactionsPresenter {
        return ProductHomeTransactionsPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productHomeNavigator)
    }
    
    private var productDetailHeaderPresenter: ProductDetailHeaderPresenter {
        return ProductDetailHeaderPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productDetailNavigator)
    }
    
    private var productDetailInfoPresenter: ProductDetailInfoPresenter {
        return ProductDetailInfoPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productDetailNavigator)
    }
    
    func productHomeDialogPresenter(withOptions options: [ProductOption]) -> ProductHomeDialogPresenter {
        return ProductHomeDialogPresenter(options: options, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.productHomeNavigator)
    }
    
    func monthSelectionDialogPresenter(card: Card, withMonths months: [String], delegate: CardPdfLauncher, placeholders: [StringPlaceholder]? = nil) -> MonthSelectionDialogPresenter {
        return MonthSelectionDialogPresenter(card: card, months: months, launcherProtocol: delegate, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.productHomeNavigator, placeholders: placeholders)
    }
    
    func transactionDetailPresenter(with profile: TransactionDetailProfile) -> TransactionDetailPresenter {
        return TransactionDetailPresenter(share: sharePresenter, profile: profile, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.transactionDetailNavigator)
    }
    
    var personalManagerContainerPresenter: PersonalManagerContainerPresenter {
        return PersonalManagerContainerPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.personalManagerNavigator)
    }
    
    var personalAreaPresenter: PersonalAreaPresenter {
        return PersonalAreaPresenter(localAuthentication: localAuthentication, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.personalAreaNavigator)
    }
    
    var customerServicePresenter: CustomerServicePresenter {
        return CustomerServicePresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.customerServiceNavigator)
    }
    
    func servicesForYouPresenter(category: Category) -> ServicesForYouPresenter {
        return ServicesForYouPresenter(category: category, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.privateHomeNavigator)
    }
    
    var customizeAppPresenter: CustomizeAppPresenter {
        return CustomizeAppPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.personalAreaNavigator)
    }
    
    var customizeAvatarPresenter: CustomizeAvatarPresenter {
        return CustomizeAvatarPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.personalAreaNavigator)
    }
    
    var visualOptionsPresenter: PersonalAreaVisualOptionsPresenter {
        return PersonalAreaVisualOptionsPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.personalAreaNavigator)
    }

    var permissionsPresenter: PermissionsPresenter {
        return PermissionsPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.personalAreaNavigator)
    }
    
    // MARK: - Office managers

    func officeWithoutManagerPresenter(otherManagers: [Manager]) -> OfficeWithoutManagerPresenter {
        return OfficeWithoutManagerPresenter(sessionManager: sessionManager,
                                             dependencies: dependencies,
                                             navigator: navigatorProvider.personalManagerNavigator,
                                             otherManagers: otherManagers)
    }

    func officeWithManagerPresenter(officeManagers: [Manager], otherManagers: [Manager]) -> OfficeWithManagerPresenter {
        return OfficeWithManagerPresenter(sessionManager: sessionManager,
                                          dependencies: dependencies,
                                          navigator: navigatorProvider.personalManagerNavigator,
                                          managers: officeManagers,
                                          otherManagers: otherManagers)
    }

    // MARK: - Personal managers

    func personalWithoutManagerPresenter(isEmptyView: Bool, otherManagers: [Manager]) -> PersonalWithoutManagerPresenter {
        return PersonalWithoutManagerPresenter(sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.personalManagerNavigator, isEmptyView: isEmptyView, otherManagers: otherManagers)
    }
    
    func personalWithManagerPresenter(personalManagers: [Manager], otherManagers: [Manager]) -> PersonalWithManagerPresenter {
        return PersonalWithManagerPresenter(sessionManager: sessionManager,
                                            dependencies: dependencies,
                                            navigator: navigatorProvider.personalManagerNavigator,
                                            managers: personalManagers,
                                            otherManagers: otherManagers)
    }
    
    // MARK: - PDF
    func pdfViewerPresenter(pdfData: Data, title: String, pdfSource: PdfSource) -> PDFViewerPresenter {
        return PDFViewerPresenter(pdf: pdfData, pdfSource: pdfSource, title: title, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    func appInfoPresenter(appInfo: AppInfoDO) -> AppInfoPresenter {
        return AppInfoPresenter(dependencies, sessionManager: sessionManager, navigator: navigatorProvider.appInfoNavigator, appInfo: appInfo)
    }

    func personalAreaFrequentOperativesPresenter() -> PersonalAreaFrequentOperativesPresenter {
        return PersonalAreaFrequentOperativesPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.personalAreaNavigator)
    }
    
    func wkWebViewPresenter(config: WebViewConfiguration,
                            javascriptHandler: WebViewJavascriptHandler?,
                            linkHandler: WebViewLinkHandler?,
                            backAction: WebViewBackAction = .automatic,
                            didCloseClosure: ((Bool) -> Void)? = nil) -> BaseWebViewPresenter {
        let presenter = BaseWebViewPresenter(webView: WKWebView(frame: .zero),
                                             webViewDelegate: WKWebViewDelegate(dependenciesResolver: dependenciesEngine),
                                             webViewConfiguration: config,
                                             javascriptHandler: javascriptHandler,
                                             linkHandler: linkHandler,
                                             dependencies: dependencies,
                                             sessionManager: sessionManager,
                                             navigator: navigatorProvider.baseWebViewNavigator,
                                             backAction: backAction,
                                             didCloseClosure: didCloseClosure,
                                             loadingTipPresenter: loadingTipPresenter)
        
        return presenter
    }
    
    func webViewPresenter(for webView: WebView,
                          webViewDelegate: BaseWebViewDelegate,
                          config: WebViewConfiguration,
                          javascriptHandler: WebViewJavascriptHandler?,
                          linkHanlder: WebViewLinkHandler?,
                          backAction: WebViewBackAction = .automatic,
                          didCloseClosure: ((Bool) -> Void)? = nil) -> BaseWebViewPresenter {
        return BaseWebViewPresenter(webView: webView,
                                    webViewDelegate: webViewDelegate,
                                    webViewConfiguration: config,
                                    javascriptHandler: javascriptHandler,
                                    linkHandler: linkHanlder,
                                    dependencies: dependencies,
                                    sessionManager: sessionManager,
                                    navigator: navigatorProvider.baseWebViewNavigator,
                                    backAction: backAction,
                                    didCloseClosure: didCloseClosure,
                                    loadingTipPresenter: loadingTipPresenter)
    }
    
    // MARK: - Tips
    
    func tipsPresenter() -> TipsPresenter {
        return TipsPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.tipsNavigator)
    }
    
    // MARK: Pull Offers
    
    func pullOfferBannerPresenter(offers: [Offer], categoryId: String) -> PullOfferBannerPresenter {
        return PullOfferBannerPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.pullOfferBannerNavigator, offers: offers, categoryId: categoryId)
    }
    
    func tutorialPresenter(config: PullOffersTutorialConfiguration) -> TutorialPresenter {
        let presenter = TutorialPresenter(tutorialConfiguration: config, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.privateHomeNavigator)
        return presenter
    }
    
    func tutorialDetailPresenter(with page: TutorialPage) -> TutorialDetailPresenter {
        return TutorialDetailPresenter(tutorialDetail: page, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    func pullOfferDetailPresenter(config: PullOffersDetailConfiguration) -> PullOfferDetailPresenter {
        return PullOfferDetailPresenter(detailConfiguration: config, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.privateHomeNavigator)
    }
    
    func creativityPresenter(with config: PullOffersCreativityConfiguration) -> CreativityOfferPresenter {
        return CreativityOfferPresenter(configuration: config, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.privateHomeNavigator)
    }
    
    func imageListFullscreenPresenter(with config: PullOffersImageListConfiguration) -> ImageListFullscreenPresenter {
        return ImageListFullscreenPresenter(pullOffersImageListConfiguration: config, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.privateHomeNavigator)
    }
    
    func imageFullScreenPresenter(with page: ListPageDTO) -> ImageListFullscreenPagePresenter {
        return ImageListFullscreenPagePresenter(page: page, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    // MARK: - Transfers
    
    func transferDetailPresenter(with transferDetailData: TransferDetailDataType) -> TransferDetailPresenter {
        return TransferDetailPresenter(transferDetailData: transferDetailData, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.transferEmittedDetailNavigator)
    }
    
    func cancelTransferConfirmationPresenter(transferScheduled: TransferScheduled, scheduledTransferDetail: ScheduledTransferDetail, account: Account, operativeDelegate: OperativeLauncherDelegate) -> CancelTransferConfirmationPresenter {
        return CancelTransferConfirmationPresenter(transferScheduled: transferScheduled, scheduledTransferDetail: scheduledTransferDetail, account: account, operativeDelegate: operativeDelegate, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.cancelTransferConfirmationNavigator)
    }
    
    // MARK: - One Pay
    
    var onePayTransferAccountSelectorPresenter: OnePayAccountSelectorPresenter {
        return OnePayAccountSelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    var onePayTransferSelectorPresenter: OnePayTransferSelectorPresenter {
        return OnePayTransferSelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    var onePayTransferDestinationPresenter: OnePayTransferDestinationPresenter {
        return OnePayTransferDestinationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    var onePayTransferConfirmationPresenter: OnePayTransferConfirmationPresenter {
        return OnePayTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    var onePayTransferSelectorSubtypePresenter: OnePayTransferSelectorSubtypePresenter {
        return OnePayTransferSelectorSubtypePresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    func onePayTransferFavouritesPresenter(delegate: OnePayTransferDestinationDelegate, country: SepaCountryInfo, currency: SepaCurrencyInfo, favourites: [FavoriteType]) -> OnePayTransferFavouritesPresenter {
        return OnePayTransferFavouritesPresenter(delegate: delegate, country: country, currency: currency, favourites: favourites, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    func onePayNoSepaTransferFavouritesPresenter(delegate: OnePayTransferDestinationDelegate, country: SepaCountryInfo, currency: SepaCurrencyInfo) -> OnePayNoSepaTransferFavouritesPresenter {
        return OnePayNoSepaTransferFavouritesPresenter(delegate: delegate, country: country, currency: currency, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    func onePayDialogOnePayPresenter(delegate: DialogOnePayDelegate) -> DialogOnePayPresenter {
        return DialogOnePayPresenter(delegate: delegate, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    var usualTransferAccountSelectorPresenter: UsualTransferAccountSelectorPresenter {
        return UsualTransferAccountSelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
         
    var usualTransferSelectorSubtypePresenter: UsualTransferSelectorSubtypePresenter {
        return UsualTransferSelectorSubtypePresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var usualTransferAmountEntryPresenter: UsualTransferAmountEntryPresenter {
        return UsualTransferAmountEntryPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    var usualTransferConfirmationPresenter: UsualTransferConfirmationPresenter {
        return UsualTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var reemittedTransferAccountSelectorPresenter: ReemittedTransferAccountSelectorPresenter {
        return ReemittedTransferAccountSelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var reemittedTransferAmountEntryPresenter: ReemittedTransferAmountEntryPresenter {
        return ReemittedTransferAmountEntryPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    var reemittedTransferSelectorSubtypePresenter: ReemittedTransferSelectorSubtypePresenter {
        return ReemittedTransferSelectorSubtypePresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    var reemittedTransferConfirmationPresenter: ReemittedTransferConfirmationPresenter {
        return ReemittedTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onePayTransferNavigator)
    }
    
    // MARK: - Usual Transfer Payee
    var createUsualTransferCountryCurrencySelectorPresenter: CreateUsualTransferCountryCurrencySelectorPresenter {
        return CreateUsualTransferCountryCurrencySelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.usualTransferNavigator)
    }
    
    var createUsualTransferInputDataPresenter: CreateUsualTransferInputDataPresenter {
        return CreateUsualTransferInputDataPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }

    var createUsualTransferConfirmationPresenter: CreateUsualTransferConfirmationPresenter {
        return CreateUsualTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var createNoSepaUsualTransferInputDataPresenter: CreateNoSepaUsualTransferInputDataPresenter {
        return CreateNoSepaUsualTransferInputDataPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var createNoSepaUsualTransferInputDataDetailPresenter: CreateNoSepaUsualTransferInputDataDetailPresenter {
        return CreateNoSepaUsualTransferInputDataDetailPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var createNoSepaUsualTransferConfirmationPresenter: CreateNoSepaUsualTransferConfirmationPresenter {
        return CreateNoSepaUsualTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var updateUsualTransferCountryCurrencySelectorPresenter: UpdateUsualTransferCountryCurrencySelectorPresenter {
        return UpdateUsualTransferCountryCurrencySelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.usualTransferNavigator)
    }
    
    var updateUsualTransferInputDataPresenter: UpdateUsualTransferInputDataPresenter {
        return UpdateUsualTransferInputDataPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var updateUsualTransferConfirmationPresenter: UpdateUsualTransferConfirmationPresenter {
        return UpdateUsualTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var updateNoSepaUsualTransferInputDataPresenter: UpdateNoSepaUsualTransferInputDataPresenter {
        return UpdateNoSepaUsualTransferInputDataPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var updateNoSepaUsualTransferBankDataPresenter: UpdateNoSepaUsualTransferBankDataPresenter {
        return UpdateNoSepaUsualTransferBankDataPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var updateNoSepaUsualTransferConfirmationPresenter: UpdateNoSepaUsualTransferConfirmationPresenter {
        return UpdateNoSepaUsualTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
        
    // MARK: - One Pay No Sepa
    
    var noSepaTransferDestinationPresenter: NoSepaTransferDestinationPresenter {
        return NoSepaTransferDestinationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.noSepaNaviagator)
    }
    
    var noSepaTransferDestinationDetailPresenter: NoSepaTransferDestinationDetailPresenter {
        return NoSepaTransferDestinationDetailPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.noSepaNaviagator)
    }
    
    // MARK: Push MailBox
    
    func onlineMessagesWKWebViewPresenter(webViewConfiguration: WebViewConfiguration, linkHandler: WebViewLinkHandler) -> OnlineMessagesWebViewPresenter {
        let presenter = OnlineMessagesWebViewPresenter(webView: WKWebView(frame: .zero),
                                                       webViewDelegate: WKWebViewDelegate(dependenciesResolver: dependenciesEngine),
                                                       webViewConfiguration: webViewConfiguration,
                                                       linkHandler: linkHandler,
                                                       dependencies: dependencies,
                                                       sessionManager: sessionManager,
                                                       navigator: navigatorProvider.baseWebViewNavigator,
                                                       loadingTipPresenter: loadingTipPresenter)
        
        return presenter
    }
    
    func pushMailBoxPresenter(options: [InboxTabList], currentOption: InboxTabList) -> PushMailBoxPresenter<PushMailBoxNavigator> {
        return PushMailBoxPresenter(options, currentOption: currentOption, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.pushMailBoxNavigator)
    }
    
    // MARK: - Card Limit
    
    var cardLimitPresenter: CardLimitPresenter {
        return CardLimitPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.cardLimitNavigator)
    }
    
    var cardLimitManagementConfirmationPresenter: CardLimitManagementConfirmationPresenter {
        return CardLimitManagementConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    // MARK: - Logout dialog
    
    var logoutByePresenter: LogoutByePresenter {
        let presenter = LogoutByePresenter(dependenciesResolver: dependenciesEngine)
        presenter.view = LogoutByeViewController(nibName: "LogoutByeViewController", bundle: .module, presenter: presenter)
        return presenter
    }
    
    func logoutDialog(acceptAction: @escaping () -> Void, offerDidOpenAction: @escaping () -> Void) -> LogoutDialogPresenter {
        return LogoutDialogPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.logoutNavigator, acceptAction: acceptAction, offerDidOpenAction: offerDidOpenAction)
    }
    
    // MARK: - Landing Push
    func landingPushPresenter(cardTransactionInfo: CardTransactionPush?, cardAlertInfo: CardAlertPush?) -> LandingPushPresenter {
        return LandingPushPresenter(cardTransactionInfo: cardTransactionInfo, cardAlertInfo: cardAlertInfo, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.landingPushLauncherNavigator)
    }
    
    func genericLandingPushPresenter(accountTransactionInfo: AccountLandingPushData) -> AccountLandingPushPresenter {
        return AccountLandingPushPresenter(accountPushInfo: accountTransactionInfo, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.genericLandingPushLauncherNavigator)
    }
        
    // MARK: - One pay transfer summary
    
    var sepaTransferSummaryPresenter: SepaTransferSummaryPresenter {
        let presenter = SepaTransferSummaryPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.operativeSummaryNavigator)
        presenter.sharePresenter = sharePresenter
        return presenter
    }
    
    var noSepaTransferSummaryPresenter: NoSepaTransferOperativeSummaryPresenter {
        let presenter = NoSepaTransferOperativeSummaryPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.operativeSummaryNavigator)
        presenter.sharePresenter = sharePresenter
        return presenter
    }
    
    // MARK: - One pay transfer lisboa summary
    
    var onePayTransferLisboaSummaryPresenter: OperativeSummaryLisboaPresenter {
        OperativeSummaryLisboaPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.operativeSummaryNavigator)
    }
    
    // MARK: - List Dialog
    
    func listDialogPresenter(title: LocalizedStylableText, items: [ListDialogItem], type: ListDialogType) -> ListDialogPresenter {
        return ListDialogPresenter(title: title, items: items, type: type, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.listDialogNavigator)
    }
    
    // MARK: - OTPPush
    
    var enableOtpPushChangeAliasPresenter: EnableOtpPushChangeAliasPresenter {
        return EnableOtpPushChangeAliasPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    func otpPushInfoPresenter(device: OTPPushDevice) -> OTPPushInfoPresenter {
        return OTPPushInfoPresenter(device: device, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.otpPushInfoNavigator)
    }
    
    var changeMassiveDirectDebitsConfirmationPresenter: ChangeMassiveDirectDebitsConfirmationPresenter {
        return ChangeMassiveDirectDebitsConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }

    // MARK: - SCA
    
    func otpScaLoginPresenter(username: String, isFirstTime: Bool) -> OtpScaLoginPresenter {
        return OtpScaLoginPresenter(username: username, isFirstTime: isFirstTime, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.otpScaLoginNavigator)
    }
    
    // MARK: - OTP
    
    var otpScaAccountPresenter: OtpScaAccountPresenter {
        return OtpScaAccountPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.otpScaAccountNavigator)
    }
    
    var lisboaOtpScaAccountPresenter: LisboaOtpScaAccountPresenter {
        return LisboaOtpScaAccountPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.otpScaAccountNavigator)
    }
    
    // MARK: - Onboarding
    
    var onboardingWelcomePresenter: OnboardingWelcomePresenter {
        return OnboardingWelcomePresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onboardingNavigator)
    }
    
    var onboardingLanguagesPresenter: OnboardingLanguagesPresenter {
        return OnboardingLanguagesPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onboardingNavigator)
    }
    
    var onboardingChangeAliasPresenter: OnboardingChangeAliasPresenter {
        return OnboardingChangeAliasPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onboardingNavigator)
    }
    
    var onboardingOptionsPresenter: OnboardingOptionsPresenter {
        return OnboardingOptionsPresenter(localAuthentication: localAuthentication, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onboardingNavigator)
    }
    
    var onboardingGlobalPositionPagerPresenter: OnboardingGlobalPositionPagerPresenter {
        return OnboardingGlobalPositionPagerPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onboardingNavigator)
    }
    
    var onboardingPhotoThemePagerPresenter: OnboardingPhotoThemePagerPresenter {
        return OnboardingPhotoThemePagerPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.onboardingNavigator)
    }
    
    var onboardingFinalPresenter: OnboardingFinalPresenter {
        return OnboardingFinalPresenter(dependencies: dependencies, navigator: navigatorProvider.onboardingNavigator, sessionManager: sessionManager, localAuthentication: localAuthentication)
    }
    
    var secureDeviceSummaryPresenter: SecureDeviceSummaryPresenter {
        return SecureDeviceSummaryPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var loadingTipPresenter: LoadingTipPresenter {
        let tipsPresenter = LoadingTipPresenter(dependenciesResolver: dependenciesEngine)
        let view = LoadingTipViewController(presenter: tipsPresenter)
        tipsPresenter.view = view
        
        return tipsPresenter
    }
    
    // MARK: - WithdrawMoney

    var withdrawMoneySummaryPresenter: WithdrawMoneySummaryPresenter {
        return WithdrawMoneySummaryPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.withdrawMoneySummaryNavigator)
    }
}
