import CoreFoundationLib
import TransferOperatives

protocol TransferHomePresenterProtocol: SuperUseCaseDelegate, ContactSelectorDelegate, MenuTextWrapperProtocol {
    var view: TransferHomeViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func didSelectViewModel(_ viewModel: TransferViewModel)
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didTapOnNewShipment()
    func didSelectScheduledTransfers()
    func didSelectContacts()
    func didSelectContact(_ viewModel: ContactViewModel)
    func didSelectNewContact()
    func didSelectVirtualAssistant()
    func didSelectHistoricalEmittedTransfers()
    func didTooltipAction()
    func didTooltipVideoAction()
    func didSwipeContacts()
    func didSwipeEmmited()
    func trackFaqEvent(_ question: String, url: URL?)
}

final class TransferHomePresenter {
    weak var view: TransferHomeViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var selectedAccount: AccountEntity?
    private let maxElements = 20
    private let transferRequest = TransferRequest()
    private var tooltipLocation: PullOfferLocation {
        PullOfferLocation(stringTag: TransferPullOffers.tooltipVideo, hasBanner: false, pageForMetrics: trackerPage.page)
    }
    private var toolTipVideoOffer: OfferEntity?
    private var isTransferBetweenAccountsAvailable: Bool?
    private var testFloatingButtonVisible: Bool = false // Remove this once the floating button is tested
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.registerForGlobalPositionReload()
        self.registerForRefreshContactNotification()
    }

    lazy var getTransferUseCase: GetTransferUseCaseProtocol? = {
        return self.dependenciesResolver.resolve(forOptionalType: GetTransferUseCaseProtocol.self)
    }()
    
    var coordinatorDelegate: TransferHomeModuleCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: TransferHomeModuleCoordinatorDelegate.self)
    }
    
    var coordinator: TransferHomeModuleCoordinator {
        return self.dependenciesResolver.resolve(for: TransferHomeModuleCoordinator.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var globalPositionV2UseCase: GetGlobalPositionV2UseCase {
        return dependenciesResolver.resolve(for: GetGlobalPositionV2UseCase.self)
    }
    
    var accountsUseCase: GetTransfersHomeUseCase {
        return self.dependenciesResolver.resolve(for: GetTransfersHomeUseCase.self)
    }
    
    private lazy var transferHomeAccountSelection: TransferHomeAccountSelectionProtocol? = {
        return self.dependenciesResolver.resolve(forOptionalType: TransferHomeAccountSelectionProtocol.self)
    }()
    
    var pullOfferUseCase: GetPullOffersUseCase {
        return self.dependenciesResolver.resolve(for: GetPullOffersUseCase.self)
    }
    
    var timeManager: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    var contactsEngine: ContactsEngineProtocol {
        return self.dependenciesResolver.resolve(for: ContactsEngineProtocol.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var getFaqsUseCase: GetFaqsUseCaseAlias {
        return self.dependenciesResolver.resolve(for: GetFaqsUseCaseAlias.self)
    }
    
    private var setTransferHomeUseCase: SetTransferHomeUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: SetTransferHomeUseCaseProtocol.self)
    }
    
    private var accountHomeModifier: TransferHomeModifier {
        self.dependenciesResolver.resolve(for: TransferHomeModifier.self)
    }
    
    var locations: [PullOfferLocation] {
        return [PullOfferLocation(stringTag: TransferPullOffers.fxpayTransferHomeOffer,
                                  hasBanner: false, pageForMetrics: trackerPage.page),
                PullOfferLocation(stringTag: TransferPullOffers.donationTransferOffer,
                                  hasBanner: false, pageForMetrics: trackerPage.page),
                PullOfferLocation(stringTag: TransferPullOffers.correosCashOffer,
                                  hasBanner: false, pageForMetrics: trackerPage.page)]
    }
    
    var offers: [PullOfferLocation: OfferEntity] = [:]
    
    @objc func usualTransferOperativeDidFinish() {
        self.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TransferHomePresenter: TransferHomePresenterProtocol {
    func didTooltipAction() {
        UseCaseWrapper(
            with: self.pullOfferUseCase.setRequestValues(requestValues: GetPullOffersUseCaseInput(locations: [self.tooltipLocation])),
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.toolTipVideoOffer = result.pullOfferCandidates[self.tooltipLocation]
                let isVideoEnabled = self.toolTipVideoOffer != nil
                self.view?.showGeneralTooltipWithVideo(isVideoEnabled)
            }, onError: { [weak self] _ in
                self?.view?.showGeneralTooltipWithVideo(false)
            }
        )
        self.trackEvent(.tooltip, parameters: [:])
    }
    
    func didTooltipVideoAction() {
        self.view?.closeTooltip { [weak self] in
            guard let self = self else { return }
            guard let offer = self.toolTipVideoOffer else { return }
            self.coordinatorDelegate.executeOffer(offer)
        }
    }
    
    func viewDidLoad() {
        self.loadIsSearchEnabled()
        self.setTransferHome()
        self.loadFaqs()
        self.trackScreen()
    }
    
    func viewWillAppear() {
        self.loadIsSearchEnabled()
    }
    
    private func loadTransferHomeData() {
        guard transferRequest.allowFeching() else { return }
        self.view?.clearEmittedTransfers()
        self.transferRequest.addRequest()
        self.loadAccounts { [weak self] accounts in
            self?.loadContacts()
            self?.loadPullOffers()
            self?.loadGlobalPositionV2(accounts: accounts)
        }
    }
    
    private func loadPullOffers() {
        self.loadPullOffers { [weak self] in
            guard let transferActions = self?.getHomeTransferActions() else { return }
            self?.view?.showTransferActions(transferActions)
        }
    }
    
    private func loadGlobalPositionV2(accounts: [AccountEntity]) {
        self.loadGlobalPositionV2 { [weak self] in
            self?.loadEmittedTransfer(for: accounts)
        }
    }
    
    private func loadFaqs() {
        self.loadFaqs { [weak self] faqs, showVirtualAssistant  in
            let viewModels = faqs.map { TransfersFaqsViewModel($0) }
            self?.view?.showFaqs(viewModels, showVirtualAssistant: showVirtualAssistant)
        }
    }
    
    private func getNewSendMoneyEnabled() -> Scenario<Void, EnabledSendMoneyUseCaseOkOutput, StringErrorOutput> {
        // Remove this once the floating button is tested
        Scenario(useCase: EnabledSendMoneyUseCase(dependenciesResolver: self.dependenciesResolver))
    }
    
    func viewWillDisappear() {
        self.transferRequest.removeRequest()
    }
    
    func didSelectContact(_ viewModel: ContactViewModel) {
        
        guard let view = self.view else { return }
        self.accountHomeModifier.didSelectContact(contact: viewModel.contact,
                                                  launcher: self,
                                                  delegate: view)
        self.trackEvent(.favoriteDetail, parameters: [:])
    }
    
    func didSelectViewModel(_ viewModel: TransferViewModel) {
        if let getTransferUseCase = getTransferUseCase {
            self.view?.showLoading()
            UseCaseWrapper(
                with: getTransferUseCase.setRequestValues(requestValues: viewModel),
                useCaseHandler: useCaseHandler,
                onSuccess: { [weak self] result in
                    guard let self = self else { return }
                    self.view?.dismissLoading(completion: {
                        let action: SendMoneyPage.Action?
                        switch result.transferType {
                        case .emitted:
                            action = .emmited
                        case .received:
                            action = .received
                        case .scheduled:
                            action = nil
                        }
                        guard let actionUnwrapped = action else { return }
                        self.showTransferDetail(result, action: actionUnwrapped)
                    })
                }, onError: { [weak self] _ in
                    guard let self = self else { return }
                    self.view?.dismissLoading(completion: {
                        self.view?.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
                    })
                }
            )
        } else {
            switch viewModel.transferType {
            case .emitted:
                guard let transfer = viewModel.transfer as? TransferEmittedEntity else { return }
                self.coordinatorDelegate.showTransferDetail(transfer,
                                                            fromAccount: self.selectedAccount,
                                                            toAccount: viewModel.account,
                                                            presentationBlock: { [weak self] in
                                                                self?.showTransferDetail($0,
                                                                                         action: .emmited)
                                                            })
            case .received:
                self.showTransferDetail(TransferDetailConfiguration.receivedConfigurationFrom(viewModel), action: .received)
            }
        }
    }
    
    func showTransferDetail(_ configuration: TransferDetailConfiguration, action: SendMoneyPage.Action) {
        self.coordinator.gotoTransferDetailWithConfiguration(configuration)
        self.trackEvent(action, parameters: [:])
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func didSelectSearch() {
        self.accountHomeModifier.didSelectSearch()
    }
    
    func didTapOnNewShipment() {
        self.coordinator.goToNewShipment(for: self.selectedAccount)
        self.trackEvent(.newSend, parameters: [:])
    }
    
    func didSelectNewContact() {
        self.accountHomeModifier.didSelectNewContact()
        self.trackEvent(.newFavorite, parameters: [:])
    }
    
    func didSelectScheduledTransfers() {
        self.coordinator.didSelectScheduledTransfers()
    }
    
    func didSelectContacts() {
        self.coordinator.didSelectContacts(self)
        self.trackEvent(.seeFavorites, parameters: [:])
    }
    
    func didSelectHistoricalEmittedTransfers() {
        self.coordinator.didSelectHistoricalEmittedTransfers()
        self.trackEvent(.seeHistoric, parameters: [:])
    }
    
    func registerForGlobalPositionReload() {
        self.dependenciesResolver.resolve(for: GlobalPositionReloadEngine.self).add(self)
    }
    
    func registerForRefreshContactNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(usualTransferOperativeDidFinish), name: Notifications.UsualTransferOperativeNotifications.operativeDidFinish, object: nil)
    }
    
    func didSelectVirtualAssistant() {
        trackEvent(.anotherQueries, parameters: [:])
        self.coordinator.goToVirtualAssistant()
    }
    
    func didSwipeContacts() {
        self.trackEvent(.swipeFavorites, parameters: [:])
    }
    
    func didSwipeEmmited() {
        self.trackEvent(.swipeEmmited, parameters: [:])
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        let eventId = url == nil ? "click_show_faq" : "click_link_faq"
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        trackerManager.trackEvent(screenId: "/send_money", eventId: eventId, extraParameters: dic)
    }
}

extension TransferHomePresenter: ContactSelectorDelegate {
    func didSortedContacts() {
        self.loadContacts()
    }
}

extension TransferHomePresenter: ModuleLauncher {}

private extension TransferHomePresenter {
    func setTransferHome() {
        Scenario(useCase: setTransferHomeUseCase)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] result in
                self?.isTransferBetweenAccountsAvailable = result.isTransferBetweenAccountsAvailable
                self?.loadTransferHomeData()
            }
    }
    
    func getHomeTransferActions() -> [TransferActionViewModel] {
        let transferBetweenAccounts = self.isTransferBetweenAccountsAvailable ?? false
        var homeActions: [TransferActionViewModel] = self.accountHomeModifier.getHomeTransferActions(transferBetweenAccounts).compactMap {
            let value = $0.values()
            guard let actionType = self.addTranferActionWithOffer(actionType: $0)
            else { return nil }
            return TransferActionViewModel(
                title: value.title,
                description: value.description,
                imageName: value.imageName,
                actionType: actionType,
                action: self.didSelectActionType
            )
        }
        
        // Remove this once the floating button is tested
        if self.testFloatingButtonVisible {
            homeActions.append(
                TransferActionViewModel(
                    title: "Test One componentes",
                    description: "Vista temporal para verificar nuevos componentes",
                    imageName: "icnBizumGrey",
                    actionType: .custome(identifier: "testOneComponents", title: "Prueba", description: "Prueba description", icon: "imgPiggyBanksBig"),
                    action: { [weak self] _ in
                        self?.coordinator.didSelectTestOneComponents()
                    })
            )
        }
        
        return homeActions
    }
    
    func didSelectActionType(_ actionType: TransferActionType) {
        self.trackTransferAction(actionType)
        self.accountHomeModifier.didSelectTransferAction(type: actionType, account: self.selectedAccount)
    }
    
    func addTranferActionWithOffer(actionType: TransferActionType) -> TransferActionType? {
        switch actionType {
        case .onePayFX:
            let fxpayOffer = offers.location(key: TransferPullOffers.fxpayTransferHomeOffer)?.offer
            guard let offer = fxpayOffer else {
                return nil
            }
            return .onePayFX(offer)
        case .donations:
            let donationOffer = offers.location(key: TransferPullOffers.donationTransferOffer)?.offer
            guard let offer = donationOffer else {
                return nil
            }
            return .donations(offer)
        case .correosCash:
            let correosCashOffer = offers.location(key: TransferPullOffers.correosCashOffer)?.offer
            guard let offer = correosCashOffer else {
                return nil
            }
            return .correosCash(offer)
        default: return actionType
        }
    }
    
    func trackTransferAction(_ type: TransferActionType) {
        switch type {
        case .transfer:
            self.trackEvent(.transfer, parameters: [:])
        case .transferBetweenAccounts:
            self.trackEvent(.internalTransfer, parameters: [:])
        case .atm:
            self.trackEvent(.moneyCode, parameters: [:])
        case .scheduleTransfers:
            self.trackEvent(.scheduled, parameters: [:])
        default: break
        }
    }
    
    func loadPullOffers(_ completion: @escaping() -> Void) {
        Scenario(useCase: pullOfferUseCase,
                 input: GetPullOffersUseCaseInput(locations: locations))
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] output  in
                self?.offers = output.pullOfferCandidates
            }
            .then(scenario: self.getNewSendMoneyEnabled)
            .onSuccess { [weak self] output  in
                // Change action to redirect to new operative
                self?.testFloatingButtonVisible = output.testFloatingButtonVisible
                completion()
            }
            .onError { _ in
                completion()
            }
    }
    
    func loadGlobalPositionV2(_ completion: @escaping() -> Void) {
        UseCaseWrapper(
            with: self.globalPositionV2UseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { _ in
                completion()
            }, onError: { _ in
                completion()
            }
        )
    }
    
    func loadFaqs(_ completion: @escaping([FaqsEntity], Bool) -> Void) {
        Scenario(useCase: self.getFaqsUseCase, input: FaqsUseCaseInput(type: .transfersHome))
            .execute(on: self.useCaseHandler)
            .onSuccess { response in
                completion(response.faqs, response.showVirtualAssistant)
            }
            .onError { _ in
                completion([], true)
            }
    }
    
    func loadAccounts(_ completion: @escaping([AccountEntity]) -> Void) {
        MainThreadUseCaseWrapper(
            with: accountsUseCase,
            onSuccess: { [weak self] response in
                self?.setSelectedAccount(response)
                completion(response.accounts)
            })
    }
    
    func loadEmittedTransfer(for accounts: [AccountEntity]) {
        guard let useCase = self.dependenciesResolver.resolve(forOptionalType: GetAllTransfersUseCaseProtocol.self) else { return }
        let input = GetAllTransfersUseCaseInput(accounts: accounts)
        Scenario(useCase: useCase.setRequestValues(requestValues: input), input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                self?.handleTransferEmitted(output.0, received: output.1)
            }
    }
    
    func loadContacts() {
        self.view?.showContactsLoading()
        self.contactsEngine.fetchContacts { result in
            guard case let .success(contacts) = result else {
                self.view?.showContacts([])
                return
            }
            let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
            let viewModels: [ContactHomeViewModel] = contacts.map {
                let colorType = colorsEngine.get($0.payeeDisplayName ?? "")
                let colorsByNameViewModel = ColorsByNameViewModel(colorType)
                return ContactHomeViewModel(contact: $0, baseUrl: self.baseURLProvider.baseURL, colorsByNameViewModel: colorsByNameViewModel)
            }
            self.view?.showContacts(viewModels)
        }
    }
    
    func handleTransferEmitted(_ transferEmitted: [AccountEntity: [TransferEmittedEntity]], received: [AccountEntity: [TransferReceivedEntity]]) {
        self.transferRequest.removeRequest()
        let total = self.makeTransferEmittedViewModels(transferEmitted) + self.makeTransferEmittedViewModels(received)
        let viewModels = Array(total
                                .sorted { $0 > $1 }
                                .prefix(maxElements))
        if viewModels.isEmpty {
            self.view?.showTransferEmittedEmptyView()
        } else {
            self.view?.showTransfersEmitted(viewModels)
        }
    }
    
    func makeTransferEmittedViewModels(_ transferEmitted: [AccountEntity: [TransferEntityProtocol]]) -> [TransferViewModel] {
        let viewModels: [TransferViewModel] = transferEmitted.reduce([]) { (result, next) in
            let account = next.key
            let viewModels = next.value.map {
                return TransferViewModel(
                    account, transfer: $0,
                    timeManager: timeManager,
                    baseUrl: baseURLProvider.baseURL
                )
            }
            return result + viewModels
        }
        return viewModels.sorted { $0 > $1 }
    }
    
    func handleTransferEmittedError(_ error: String?) {
        self.transferRequest.removeRequest()
        self.view?.showTransferEmittedEmptyView()
    }
}

extension TransferHomePresenter: AutomaticScreenEmmaActionTrackable {
    var trackerPage: SendMoneyPage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependenciesResolver.resolve()
        let emmaToken = emmaTrackEventList.transfersEventID
        return SendMoneyPage(emmaToken: emmaToken)
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension TransferHomePresenter {
    func onSuccess() {}
    
    func onError(error: String?) {
        self.handleTransferEmittedError(error)
    }
}

extension TransferHomePresenter: GlobalPositionReloadable {
    func reload() {
        self.viewDidLoad()
    }
}

extension TransferHomePresenter: GlobalSearchEnabledManagerProtocol {
    private func loadIsSearchEnabled() {
        self.getIsSearchEnabled(with: dependenciesResolver) { [weak self] (resp) in
            self?.view?.isSearchEnabled = resp
        }
    }
}

final class TransferRequest {
    private var isFeching = false
    
    func allowFeching() -> Bool {
        return !self.isFeching
    }
    
    func addRequest() {
        self.isFeching = true
    }
    
    func removeRequest() {
        self.isFeching = false
    }
}

private extension TransferHomePresenter {
    func setSelectedAccount(_ output: GetTransfersHomeUseCaseOutput) {
        guard let modifier = transferHomeAccountSelection else {
            self.selectedAccount = output.configuration.selectedAccount
            return
        }
        self.selectedAccount = modifier.checkAccounts(output.accounts)
    }
}
