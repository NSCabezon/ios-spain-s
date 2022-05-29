import CoreFoundationLib

protocol InboxHomePresenterProtocol: MenuTextWrapperProtocol {
    var view: InboxHomeViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectSearch()
    func didSelectAction(type: InboxActionType)
}

final class InboxHomePresenter {
    weak var view: InboxHomeViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var coordinatorDelegate: InboxHomeModuleCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: InboxHomeModuleCoordinatorDelegate.self)
    }
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var pullOfferUseCase: GetPullOffersUseCase {
        return self.dependenciesResolver.resolve(for: GetPullOffersUseCase.self)
    }
    var pendingSolicitudesUseCase: GetPendingSolicitudesUseCase {
        return self.dependenciesResolver.resolve(for: GetPendingSolicitudesUseCase.self)
    }
    var coordinator: InboxHomeCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: InboxHomeCoordinatorProtocol.self)
    }
    var webViewConfigurationUseCase: GetOnlineMessagesWebViewConfigurationUseCase {
        return self.dependenciesResolver.resolve(for: GetOnlineMessagesWebViewConfigurationUseCase.self)
    }
    var getInboxAppConfigUseCase: GetInboxAppConfigUseCase {
        return self.dependenciesResolver.resolve(for: GetInboxAppConfigUseCase.self)
    }
    var removeSavedPendingSolicitudesUseCase: RemoveSavedPendingSolicitudesUseCase {
        self.dependenciesResolver.resolve(for: RemoveSavedPendingSolicitudesUseCase.self)
    }
    var inboxActionBuilderProtocol: InboxActionBuilderProtocol {
        return self.dependenciesResolver.resolve(for: InboxActionBuilderProtocol.self)
    }
    var inboxActionDelegate: InboxActionDelegate {
        return self.dependenciesResolver.resolve(for: InboxActionDelegate.self)
    }
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().inbox
    }
    var offers: [PullOfferLocation: OfferEntity] = [:]
    private var showDocumentation: Bool = false
    private var showEcommerce: Bool = false
    private var webConfiguration: WebViewConfiguration?
}

extension InboxHomePresenter: InboxHomePresenterProtocol {
    func didSelectSearch() {
        let localAppConfig = self.dependenciesResolver.resolve(for: LocalAppConfig.self)
        if localAppConfig.isEnabledMagnifyingGlass {
            self.coordinatorDelegate.didSelectSearch()
        } else {
            self.view?.didToast()
        }
    }
    
    func viewDidLoad() {
        self.getIsSearchEnabled()
        trackScreen()
        loadViewData()
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func didSelectAction(type: InboxActionType) {
        self.coordinator.didSelectAction(type: type)
    }
}

private extension InboxHomePresenter {
    func loadViewData() {
        self.loadPullOffers { [weak self] in
            self?.loadWebConfiguration { [weak self] webConfiguration in
                self?.webConfiguration = webConfiguration
                self?.setInitialInboxData()
                self?.loadPendingSolicitudes { [weak self] solicitudes in
                    self?.setInboxData(for: solicitudes)
                }
            }
        }
    }
    
    func loadPendingSolicitudes(_ completion: @escaping ([PendingSolicitudeEntity]) -> Void) {
        UseCaseWrapper(
            with: self.pendingSolicitudesUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { result in
                let pendingSolicitudes = result.response.pendingSolicitudes
                completion(pendingSolicitudes)
            }, onError: { _ in
                completion([])
            })
    }
    
    func loadPullOffers(_ completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: self.pullOfferUseCase.setRequestValues(requestValues: GetPullOffersUseCaseInput(locations: locations)),
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.offers = result.pullOfferCandidates
                completion()
            }, onError: {_ in
                completion()
        })
    }
    
    func loadAppConfigNodes() -> ScenarioHandler<GetDocumentationUseCaseOutput, StringErrorOutput> {
        Scenario(useCase: self.getInboxAppConfigUseCase)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] result in
                self?.showDocumentation = result.isPersonalDocsEnabled
                self?.showEcommerce = result.isEcommerceEnabled
            }
    }
    
    func loadWebConfiguration(_ completion: @escaping (WebViewConfiguration?) -> Void) {
        UseCaseWrapper(
            with: self.webViewConfigurationUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { result in
                completion(result.configuration)
            }, onError: { _ in
                completion(nil)
            })
    }
    
    func setInboxData(for pendingSolicitudes: [PendingSolicitudeEntity]) {
        let inboxContractSlider = self.getOfferForLocation(InboxPullOffers.inboxContractSlider)
        let solicitudesViewModels = pendingSolicitudes.map {
            PendingSolicitudeInboxViewModel($0, offer: inboxContractSlider, action: self.didSelectSlideOffer )
        }
        self.view?.showPendingSolicitudes(solicitudesViewModels)
        loadAppConfigNodes()
            .finally { [weak self] in
                self?.setInboxAction(solicitudesViewModels.first)
            }
    }
    
    func setInboxAction(_ pendingSolicitud: PendingSolicitudeInboxViewModel?) {
        let actionViewModels: [InboxActionViewModel]
        let onlineOffer = self.getOfferForLocation(InboxPullOffers.inboxMessages)
        if let inboxActionBuilderProtocol: InboxActionBuilderProtocol = self.dependenciesResolver.resolve(forOptionalType: InboxActionBuilderProtocol.self) {
            inboxActionBuilderProtocol.addDelegate(self.inboxActionDelegate)
            inboxActionBuilderProtocol.webViewConfigurationEnabled(self.webConfiguration != nil)
            actionViewModels = inboxActionBuilderProtocol.addInboxActionViewModel(offerOnLine: onlineOffer)
            inboxActionBuilderProtocol.trackTapNotificationInbox { [weak self] in
                self?.trackEvent(.tapOnNotifications)
            }
        } else {
            let bankStatementOffer = self.getOfferForLocation(InboxPullOffers.privateBankStatement)
            let inboxSetup = self.getOfferForLocation(InboxPullOffers.inboxSetup)
            let inboxContact = self.getOfferForLocation(InboxPullOffers.inboxContract)
            let inboxDocumentation = self.getOfferForLocation(InboxPullOffers.inboxDocumentation)
            let inboxFioc = self.getOfferForLocation(InboxPullOffers.inboxFioc)
            actionViewModels = InboxActionBuilder(isWebViewConfiguration: self.webConfiguration != nil,
                                                  delegate: self.inboxActionDelegate,
                                                  dependenciesResolver: self.dependenciesResolver)
                .addSantanderKey(isEnabled: showEcommerce)
                .addOnlineInbox(onlineOffer)
                .addPrivateBankStatement(bankStatementOffer)
                .addInboxSetup(inboxSetup)
                .addContract(inboxContact, pendingSolicitud)
                .addPersonalDocument(showDocumentation: (showDocumentation), offer: inboxDocumentation)
                .addFioc(inboxFioc)
                .build()
        }
        self.view?.showActions(actionViewModels)
    }
    
    func getOfferForLocation(_ location: String) -> OfferEntity? {
        return self.offers.location(key: location)?.offer
    }
    
    func setInitialInboxData() {
        _ = self.getOfferForLocation(InboxPullOffers.inboxContractSlider)
        loadAppConfigNodes()
            .finally { [weak self] in
                self?.setInboxAction(nil)
            }
    }
    
    func removeSevedPendingSolicitudes() {
        UseCaseWrapper(
            with: self.removeSavedPendingSolicitudesUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { _ in },
            onError: { _ in
            })
    }
}

extension InboxHomePresenter: AutomaticScreenActionTrackable {
    var trackerPage: InboxHomePage {
        return InboxHomePage()
    }
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension InboxHomePresenter: GlobalSearchEnabledManagerProtocol {
    private func getIsSearchEnabled() {
        self.getIsSearchEnabled(with: dependenciesResolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
}

extension InboxHomePresenter: InboxActionDelegate {
    func didSelectSlideOffer(_ offer: OfferEntity?) {
        self.removeSevedPendingSolicitudes()
        self.coordinatorDelegate.didSelectOffer(offer)
    }
    
    func didSelectOffer(_ offer: OfferEntity?) {
        self.coordinatorDelegate.didSelectOffer(offer)
    }
    
    func didSelectWebAction(_ inboxActionExtras: InboxActionExtras?) {
        self.coordinatorDelegate.didSelectOnlineInbox(self.webConfiguration)
    }
    
    func gotoInboxNotification(_ inboxActionExtras: InboxActionExtras?) {
        self.coordinator.gotoInboxNotification(showHeader: inboxActionExtras?.offer != nil)
    }
    
    func didToast(_ inboxActionExtras: InboxActionExtras?) {
        self.view?.didToast()
    }
}
