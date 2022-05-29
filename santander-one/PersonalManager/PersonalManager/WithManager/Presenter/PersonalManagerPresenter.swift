import CoreFoundationLib
import Operative

typealias PersonalManagerPresenterProtocols = (PersonalManagerPresenterProtocol & ManagerActionsDelegate & MenuTextWrapperProtocol)

protocol PersonalManagerPresenterProtocol {
    var view: PersonalManagerViewProtocol? { get set }
    var coordinator: ModuleSectionInternalCoordinator? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func searchAction()
    func drawerAction()
    func goBackAction()
    func moreInfoAction()
}

protocol ManagerActionsDelegate: class {
    func start(_ action: ManagerAction, managerType: ManagerType, forManagerWithCode code: String)
    func rateManager(withCode managerCode: String)
    func imageActionForManager(withCode managerCode: String)
    func showEmailAlert()
}

final class PersonalManagerPresenter {
    
    weak var view: PersonalManagerViewProtocol?
    weak var coordinator: ModuleSectionInternalCoordinator?
    let dependenciesResolver: DependenciesResolver
    private var enableSidebarManagerNotifications = false
    private var managerWallEnabled: Bool?
    private var salesforceManagerWall: Bool?
    private var shouldShowNoManagerView: Bool {
        return personalManagers.count == 0 && officeManagers.count == 0 && bankManagers.count == 0
    }
    private var personalManagers: [ManagerViewModel] = []
    private var officeManagers: [ManagerViewModel] = []
    private var bankManagers: [ManagerViewModel] = [] {
        willSet {
            if !newValue.isEmpty {
                view?.changeToBankerNavigationBar()
            }
        }
    }
    private var hobbies: [ManagerHobbieEntity] = []
    private var candidate: (PullOfferLocation, OfferEntity)?
    private var userId: String = ""
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

// MARK: Private

private extension PersonalManagerPresenter {
    var personalManagerCoordinator: PersonalManagerMainModuleCoordinatorDelegate {
        return dependenciesResolver.resolve(for: PersonalManagerMainModuleCoordinatorDelegate.self)
    }
    
    var baseUrlProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var getManagersInfoUseCase: GetManagersInfoUseCase {
        return dependenciesResolver.resolve()
    }
    
    var getClick2CallUseCase: GetClick2CallUseCase {
        return dependenciesResolver.resolve(for: GetClick2CallUseCase.self)
    }
    
    func getManagersInfo() {
        UseCaseWrapper(
            with: getManagersInfoUseCase,
            useCaseHandler: dependenciesResolver.resolve(),
            onSuccess: { [weak self] response in
                self?.personalManagerCoordinator.hideLoading {
                    self?.handleResponse(response)
                }
            },
            onError: { [weak self] _ in
                self?.personalManagerCoordinator.hideLoading {
                    self?.refreshInterface()
                }
            }
        )
    }
    
    func handleResponse(_ response: GetManagersInfoUseCaseOkOutput) {
        userId = response.userId
        candidate = response.managerPullOffer
        hobbies = response.hobbies
        officeManagers = createManagerViewModel(from: response, list: response.officeManagers, type: .office)
        personalManagers = createManagerViewModel(from: response, list: response.personalManagers, type: .personal)
        bankManagers = createManagerViewModel(from: response, list: response.bankManagers, type: .banker)
        trackScreen()
        refreshInterface()
        getManagerWallState()
    }
    
    func getHobbies(for manager: ManagerViewModel) {
        guard
            let hobbies = hobbies as? [ManagerHobbieEntity],
            let hobbie = hobbies.first(where: { manager.managerCode.contains($0.managerId) })
            else { return }
        let managerDetailViewModel = ManagerDetailViewModel(
            managerName: manager.formattedName,
            managerHobbies: hobbie.descHobbies,
            imageUrl: manager.image
        )
        view?.showManagerDetailViewWith(viewModel: managerDetailViewModel)
    }
    
    func getManagers() {
        personalManagerCoordinator.showLoading(completion: { [weak self] in
            self?.getManagersInfo()
        })
    }
    
    func refreshInterface() {
        if shouldShowNoManagerView {
            coordinator?.switchToChildSection(.withoutManager)
        } else {
            drawOneBankerBackgroundIfNeeded()
            setManagers()
            view?.personalManagerBanner(isVisible: personalManagers.count == 0 && bankManagers.count == 0)
        }
    }
    
    func drawOneBankerBackgroundIfNeeded() {
        guard personalManagers.isEmpty, officeManagers.isEmpty, !bankManagers.isEmpty else { return }
        view?.setOnlyOneBankerBackground()
    }
    
    func setManagers() {
        view?.setBanker(managers: bankManagers)
        view?.setPersonal(managers: personalManagers, toBankerView: bankManagers.isEmpty)
        view?.setOffice(managers: officeManagers)
    }
    
    func getManager(with identifier: String) -> ManagerViewModel? {
        return bankManagers.first { $0.managerCode == identifier } ??
            personalManagers.first { $0.managerCode == identifier } ??
            officeManagers.first { $0.managerCode == identifier }
    }
    
    func createManagerViewModel(from response: GetManagersInfoUseCaseOkOutput, list: ManagerList, type: ManagerType) -> [ManagerViewModel] {
        return ManagerViewModel.initWith(
            list,
            type: type,
            managerWallEnabled: response.managerWallEnabled,
            videoCallEnabled: response.videoCallEnabled,
            calendarEnabled: response.managerPullOffer != nil,
            hobbies: hobbies,
            baseUrl: self.baseUrlProvider.baseURL
        )
    }
}

// MARK: PersonalManagerPresenterProtocol

extension PersonalManagerPresenter: PersonalManagerPresenterProtocol {
    
    func viewDidLoad() {
        getManagers()
        getIsSearchEnabled()
    }
    
    func viewWillAppear() {
        getManagerWallState()
    }
    
    func searchAction() { personalManagerCoordinator.didSelectSearch() }
    func drawerAction() { personalManagerCoordinator.didSelectMenu() }
    func goBackAction() { personalManagerCoordinator.didSelectDismiss() }
    func moreInfoAction() { personalManagerCoordinator.open(url: personalManagerCustomerSupportURL) }
}

// MARK: ManagerActionsDelegate

extension PersonalManagerPresenter: ManagerActionsDelegate {
    func start(_ action: ManagerAction, managerType: ManagerType, forManagerWithCode code: String) {
        switch action {
        case .calendar:
            self.scheduleMeetingWithManager(withCode: code)
        case .chat:
            self.chatManager(withCode: code)
        case .email:
            self.sendMailToManager(withCode: code)
        case .phone:
            self.callManager(withCode: code)
        case .videoCall:
            self.videoCall()
        }
    }
    
    private func trackEvent(_ action: PersonalManagerPage.Action, managerCode: String) {
        guard let manager = getManager(with: managerCode) else { return }
        self.trackEvent(action, parameters: [.managerType: manager.type.tracker()])
    }
    
    private func callManager(withCode managerCode: String) {
        let useCaseHandler: UseCaseHandler = dependenciesResolver.resolve(for: UseCaseHandler.self)
        guard let manager = self.getManager(with: managerCode) else { return }
        UseCaseWrapper(with: getClick2CallUseCase, useCaseHandler: useCaseHandler, onSuccess: { [weak self] result in
            let telephone = manager.phone.replacingOccurrences(of: " ", with: "") + (result.contactPhone)
            self?.personalManagerCoordinator.open(url: "tel://\(telephone)")
            }, onError: { (_) in
                self.personalManagerCoordinator.open(url: "tel://\(manager.phone.replacingOccurrences(of: " ", with: ""))")
        })
        self.trackEvent(.call, managerCode: managerCode)
    }
    
    func rateManager(withCode managerCode: String) {
        personalManagerCoordinator.handleOpinator(RegularOpinatorInfoEntity(titleKey: "toolbar_title_valueManager",
                                                                            path: "Valoracion_Gestor/",
                                                                            params: [ManagerOpinatorParameter(key: managerCode)]))
        self.trackEvent(.rate, managerCode: managerCode)
    }
    
    private func videoCall() {
        let configuration = dependenciesResolver.resolve(for: PersonalManagerConfiguration.self)
        let input = SingleSignOnUseCaseInput(dependenciesResolver: dependenciesResolver, sharedTokenAccessGroup: configuration.sharedTokenAccessGroup)
        let useCase = dependenciesResolver.resolve(for: SingleSignOnUseCase.self)
        let useCaseHandler: UseCaseHandler = dependenciesResolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: input), useCaseHandler: useCaseHandler, onSuccess: { [weak self] in
            self?.open(type: .videoCall)
        })
    }
    
    private func chatManager(withCode managerCode: String) {
        let input = GetManagerWallDataUseCaseInput(managerCodGest: managerCode, dependenciesResolver: dependenciesResolver)
        let useCase = dependenciesResolver.resolve(for: GetManagerWallDataUseCase.self)
        let useCaseHandler: UseCaseHandler = dependenciesResolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: input), useCaseHandler: useCaseHandler, onSuccess: { [weak self] (resp) in
            self?.personalManagerCoordinator.openChatWith(configuration: resp.configuration)
            }, onError: { _ in
                
        })
        self.trackEvent(.chat, managerCode: managerCode)
    }
    
    private func sendMailToManager(withCode managerCode: String) {
        guard let manager = getManager(with: managerCode) else { return }
        let subject = userId.isEmpty ? nil : localized("manager_label_writeMail", [StringPlaceholder(.value, userId)]).text
        view?.openMailComposerWith(subject: subject, to: manager.email)
        self.trackEvent(.email, managerCode: managerCode)
    }
    
    private func scheduleMeetingWithManager(withCode managerCode: String) {
        guard let candidate = candidate else { return }
        personalManagerCoordinator.didSelectOffer(offer: candidate.1)
        self.trackEvent(.schedule, managerCode: managerCode)
    }
    
    func imageActionForManager(withCode managerCode: String) {
        guard let manager = getManager(with: managerCode) else { return }
        getHobbies(for: manager)
    }
    
    func showEmailAlert() {
        self.personalManagerCoordinator.showDialog(acceptTitle: localized("generic_button_accept"), cancelTitle: nil, title: nil, body: localized("generic_error_settingsMail"), showsCloseButton: false, acceptAction: nil, cancelAction: nil)
    }
    
    private func open(type: SingleSignOnToApp, parameters: String? = nil) {
        if let source = type.getUrl(params: parameters), personalManagerCoordinator.canOpenUrl(source) {
            personalManagerCoordinator.open(url: source)
        } else {
            personalManagerCoordinator.openAppStore()
        }
    }
    
    private func getManagerWallState() {
        UseCaseWrapper(
            with: dependenciesResolver.resolve(for: GetManagerWallStateUseCase.self),
            useCaseHandler: dependenciesResolver.resolve(),
            onSuccess: { [weak self] response in
                self?.managerWallEnabled = response.managerWallEnabled
                self?.salesforceManagerWall = response.managerWallVersion == 2
                self?.enableSidebarManagerNotifications = response.enableManagerNotifications
                self?.getManagerNotifications()
            }
        )
    }
    
    private func getManagerNotifications() {
        guard (personalManagers.count > 0 || bankManagers.count > 0),
            enableSidebarManagerNotifications == true,
            managerWallEnabled == true,
            salesforceManagerWall == true else { return }
        UseCaseWrapper(with: dependenciesResolver.resolve(for: GetManagerNotificationUseCase.self),
                       useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
                       onSuccess: { [weak self] result in
                        self?.view?.setNotificationBadgeVisible(result.hasNewNotifications,
                                                                inView: ManagerAction.chat.accessibilityId())
        })
    }
}

// MARK: GlobalSearchEnabledManagerProtocol

extension PersonalManagerPresenter: GlobalSearchEnabledManagerProtocol {
    private func getIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
}

extension PersonalManagerPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: PersonalManagerPage {
        return PersonalManagerPage()
    }
    
    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.numPersonalManagers.key: "\(personalManagers.count)",
            TrackerDimension.numOfficeManagers.key: "\(officeManagers.count)"
        ]
    }
}

final class ManagerOpinatorParameter: OpinatorParameter {
    public var key: String
    
    init(key: String) {
        self.key = key
    }
}

extension PersonalManagerPresenter: MenuTextWrapperProtocol {}
