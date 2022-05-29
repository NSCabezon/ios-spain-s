import CoreFoundationLib
import Operative
import UI
import PdfCommons
import CoreDomain
import Cards

class ModuleCoordinatorNavigator {
    weak var drawer: BaseMenuViewController?
    let dependencies: PresentationComponent
    var errorHandler: GenericPresenterErrorHandler {
        guard let viewController = drawer?.currentRootViewController else { fatalError("There are no view controller as root") }
        return GenericPresenterErrorHandler(stringLoader: stringLoader,
                                            view: viewController,
                                            delegate: self,
                                            dependenciesResolver: self.dependenciesEngine)
    }
    var operativeNavigationController: UINavigationController? {
        return self.viewController?.presentedViewController as? UINavigationController ?? self.viewController?.navigationController
    }
    var viewController: UIViewController? {
        (drawer?.currentRootViewController as? UINavigationController)?.topViewController ?? drawer?.currentRootViewController
    }
    let navigator: OperativesNavigatorProtocol
    let stringLoader: StringLoader
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    let coordinatorIdentifier: String
    
    var navigatorProvider: NavigatorProvider {
        return dependencies.navigatorProvider
    }
    
    var shouldOpenDeepLinkAutomatically: Bool {
        return true
    }
    
    var shouldRegisterAsDeeplinkHandler: Bool {
        return true
    }
    
    var launcherAccessType: DeepLinkLauncherAccessType {
        .privateAccess
    }
    
    private var loadings: [Int: LoadingActionProtocol] = [:]
    
    required init(drawer: BaseMenuViewController?,
                  dependencies: PresentationComponent,
                  navigator: OperativesNavigatorProtocol,
                  stringLoader: StringLoader,
                  dependenciesEngine: DependenciesResolver & DependenciesInjector,
                  coordinatorIdentifier: String) {
        self.drawer = drawer
        self.dependencies = dependencies
        self.navigator = navigator
        self.stringLoader = stringLoader
        self.dependenciesEngine = dependenciesEngine
        self.coordinatorIdentifier = coordinatorIdentifier
        self.dependenciesEngine.register(for: OperativeContainerCoordinatorDelegate.self) { _ in
            return self
        }
    }
    
    func executeOffer(_ offer: OfferRepresentable) {
        self.executeOffer(action: offer.action, offerId: offer.identifier, location: offer.pullOfferLocation)
    }
    
    func executeDeepLink(_ deepLinkIdentifer: String) {
        if let deepLink = DeepLink.init(deepLinkIdentifer) {
            dependencies.deepLinkManager.registerDeepLink(deepLink)
        }
    }
    
    func closeModalViewControllers(_ completion: (() -> Void)? = nil ) {
        guard let presendedController = self.viewController?.navigationController?.presentedViewController else {
            completion?()
            return
        }
        presendedController.dismiss(animated: true, completion: completion)
    }
    
    func showLoading(info: LoadingInfo, tag: Int) {
        if let loading = loadings[tag] {
            loading.hideLoading(completion: nil)
        }
        loadings[tag] = LoadingCreator.createAndShowLoading(info: info)
    }
    
    func hideLoading(completion: (() -> Void)?, tag: Int) {
        if let loading = loadings[tag] {
            loading.hideLoading(completion: completion)
            loadings[tag] = nil
        }
    }
    
    func showError(keyTitle: String?,
                   keyDesc: String?,
                   phone: String?,
                   completion: (() -> Void)?) {
        self.showAlertError(keyTitle: keyTitle,
                            keyDesc: keyDesc,
                            completion: completion)
    }
}

extension ModuleCoordinatorNavigator: OperativeLauncherHandler {
    var dependenciesResolver: DependenciesResolver {
        self.dependenciesEngine
    }
    
    func showOperativeLoading(completion: @escaping () -> Void) {
        self.startOperativeLoading(completion: completion)
    }
}

extension ModuleCoordinatorNavigator: GenericPresenterhideLoadings {
    
    func hideAllLoadings(completion: (() -> Void)?) {
        LoadingCreator.hideGlobalLoading(completion: completion)
    }
    
    func startGlobalLoading(completion: (() -> Void)? = nil) {
        guard let viewController = self.viewController else { return }
        let loadingText = LoadingText(title: localized("generic_popup_loading"),
                                      subtitle: localized("loading_label_moment"))
        LoadingCreator.showGlobalLoading(loadingText: loadingText,
                                         controller: viewController,
                                         completion: completion)
    }
    
    func startCustomLoading(completion: (() -> Void)? = nil) {
        guard let viewController = self.viewController else { return }
        let loadingText = LoadingText(title: localized("login_popup_loadingData"),
                                      subtitle: localized("loading_label_moment"))
        LoadingCreator.showGlobalLoading(loadingText: loadingText,
                                         controller: viewController,
                                         completion: completion)
    }
}

extension ModuleCoordinatorNavigator: OperativeLauncherDelegate {
    
    var navigatorOperativeLauncher: OperativesNavigatorProtocol {
        return navigator
    }
    var operativeDelegate: OperativeLauncherPresentationDelegate {
        return self
    }
}

extension ModuleCoordinatorNavigator: OperativeLauncherPresentationDelegate {
    
    var errorOperativeHandler: GenericPresenterErrorHandler {
        return errorHandler
    }
    
    func startOperativeLoading(completion: @escaping () -> Void) {
        guard let viewController = self.viewController else { return }
        let text = LoadingText(title: localized("generic_popup_loading"),
                               subtitle: localized("loading_label_moment"))
        LoadingCreator.showGlobalLoading(loadingText: text,
                                         controller: viewController,
                                         completion: completion)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        LoadingCreator.hideGlobalLoading(completion: completion)
    }
    
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText,
                            withAcceptComponent accept: DialogButtonComponents,
                            withCancelComponent cancel: DialogButtonComponents?) {
        guard let viewController = self.viewController else { return }
        Dialog.alert(title: title,
                     body: message,
                     withAcceptComponent: accept,
                     withCancelComponent: cancel,
                     source: viewController)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        guard let viewController = self.operativeNavigationController else { return }
        let acceptComponents = DialogButtonComponents(titled: localized("generic_button_accept"), does: completion)
        let title: LocalizedStylableText?
        if let keyTitleUnwrapped: String = keyTitle {
            title = localized(keyTitleUnwrapped)
        } else {
            title = nil
        }
        Dialog.alert(title: title,
                     body: self.stringLoader.getWsErrorString(keyDesc ?? "generic_error_needInternetConnection"),
                     withAcceptComponent: acceptComponents,
                     withCancelComponent: nil,
                     source: viewController)
    }
}

extension ModuleCoordinatorNavigator: ProductLauncherPresentationDelegate {
    
    func startLoading() {
        startOperativeLoading(completion: {})
    }
    
    func endLoading(completion: (() -> Void)?) {
        hideOperativeLoading(completion: completion ?? {})
    }
    
    func showAlert(title: LocalizedStylableText?,
                   body message: LocalizedStylableText,
                   withAcceptComponent accept: DialogButtonComponents,
                   withCancelComponent cancel: DialogButtonComponents?) {
        showOperativeAlert(title: title,
                           body: message,
                           withAcceptComponent: accept,
                           withCancelComponent: cancel)
    }
    
    func showAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showOperativeAlertError(keyTitle: keyTitle, keyDesc: keyDesc, completion: completion)
    }
}

extension ModuleCoordinatorNavigator: PullOfferActionsPresenter {
    
    var sessionManager: CoreSessionManager {
        return dependenciesEngine.resolve(for: CoreSessionManager.self)
    }
    
    var genericErrorHandler: GenericPresenterErrorHandler {
        return errorHandler
    }
    
    var presentationView: ViewControllerProxy {
        return viewController ?? UIViewController()
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigatorProvider.privateHomeNavigator
    }
}

extension ModuleCoordinatorNavigator: ShareDelegate {
    func didShare(type: ShareType) {
        
    }
    
    func getRichStringToShare() -> String? {
        return nil
    }
    
    func getStringToShare() -> String? {
        return nil
    }
    
    func getExtraTrackShareParameters() -> [String: String]? {
        return nil
    }
}

extension ModuleCoordinatorNavigator: OpinatorLauncher {
    var baseWebViewNavigatable: BaseWebViewNavigatable {
        return navigatorProvider.privateHomeNavigator
    }
}

extension ModuleCoordinatorNavigator: OperativeContainerCoordinatorDelegate {
    func handleOpinator(_ opinator: OpinatorInfoRepresentable) {
        self.openOpinator(info: opinator) { [weak self] error in
            self?.showAlertError(keyTitle: error, keyDesc: nil, completion: nil)
        }
    }
    
    func handleGiveUpOpinator(_ opinator: OpinatorInfoRepresentable, completion: @escaping () -> Void) {
        self.openOpinator(info: opinator, backAction: .nothing, onCompletion: { _ in
            completion()
        }, onError: { _ in
            completion()
        })
    }
    
    func handleWebView(with data: Data, title: String) {
        self.navigatorProvider.baseWebViewNavigator.goToPdfViewer(
            with: data,
            andTitle: stringLoader.getString(title),
            andPdfSource: .transferSummary
        )
    }
}

extension ModuleCoordinatorNavigator: GenericErrorDialogPresentationCapable {
    var associatedGenericErrorDialogView: UIViewController {
        return self.viewController ?? UIViewController()
    }
}

extension ModuleCoordinatorNavigator: OfferCoordinatorLauncher {}
extension ModuleCoordinatorNavigator: PDFCoordinatorLauncher {
    func openPDF(_ data: Data, title: String, source: PdfSource) {
        navigatorProvider.productHomeNavigator.goToPdf(with: data, pdfSource: source, toolbarTitleKey: title)
    }
}
extension ModuleCoordinatorNavigator: CoordinatorViewControllerProvider {}
extension ModuleCoordinatorNavigator: OperativeCoordinatorLauncher {}

extension ModuleCoordinatorNavigator: VirtualAssistantLauncher {
    var virtualAssistantNavigator: BaseWebViewNavigatable {
        return baseWebViewNavigatable
    }
}

extension ModuleCoordinatorNavigator: VirtualAssistantCoordinatorLauncher {
    func goToVirtualAssistant() {
        self.openVirtualAssistant()
    }
}

extension ModuleCoordinatorNavigator: DeeplinksCoordinatorLauncher {
    func goToAccountsHome(with selected: AccountEntity) {
        self.navigatorProvider.privateHomeNavigator.present(selectedProduct: Account(selected), productHome: .accounts)
    }
    
    func goToTransfersHome() {
        self.navigatorProvider.privateHomeNavigator.goToTransfers(section: .home)
    }
    
    func goToTransfersHistory() {
        self.navigatorProvider.privateHomeNavigator.goToTransfers(section: .historical)
    }
}

extension ModuleCoordinatorNavigator: NextSettlementLauncher {
    func gotoNextSettlement(_ cardEntity: CardEntity, cardSettlementDetailEntity: CardSettlementDetailEntity, isEnabledMap: Bool) {
        self.navigatorProvider.privateHomeNavigator.gotoNextSettlement(cardEntity,
                                                                       cardSettlementDetailEntity: cardSettlementDetailEntity,
                                                                       isEnabledMap: isEnabledMap)
    }
}

extension ModuleCoordinatorNavigator: OpinatorCoordinatorLauncher {}

extension ModuleCoordinatorNavigator: FractionedPaymentsLauncher {
    func didSelectInMenu() {
        self.navigatorProvider.privateHomeNavigator.drawer.toggleSideMenu()
    }
    
    func gotoCardEasyPayOperative(card: CardEntity,
                                  transaction: CardTransactionEntity,
                                  easyPayOperativeData: EasyPayOperativeDataEntity?) {
        self.navigatorProvider.privateHomeNavigator.gotoCardEasyPayOperative(
            card: card,
            transaction: transaction,
            easyPayOperativeData: easyPayOperativeData
        )
    }
    
    func goToFractionedPaymentDetail(_ transaction: CardTransactionEntity,
                                     card: CardEntity) {
        self.navigatorProvider.privateHomeNavigator.goToFractionedPaymentDetail(
            transaction: transaction,
            card: card
        )
    }
}
