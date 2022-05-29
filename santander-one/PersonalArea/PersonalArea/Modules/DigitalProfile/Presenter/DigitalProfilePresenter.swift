import CoreFoundationLib
import CorePushNotificationsService
import CoreDomain

protocol DigitalProfilePresenterProtocol: DigitalProfileTableDelegate, MenuTextWrapperProtocol {
    var view: DigitalProfileViewProtocol? { get set }
    var dataManager: PersonalAreaDataManagerProtocol? { get set }
    var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator? { get set }
    var moduleCoordinator: DefaultDigitalProfileModuleCoordinator? { get set }
    
    func viewDidLoad()
    func viewWillAppear()
    func backButtonAction()
    func searchAction()
    func drawerAction()
    func infoAction()
}

final class DigitalProfilePresenter {
    let dependenciesResolver: DependenciesResolver
    weak var view: DigitalProfileViewProtocol?
    weak var dataManager: PersonalAreaDataManagerProtocol?
    weak var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator?
    weak var moduleCoordinator: DefaultDigitalProfileModuleCoordinator?
    
    private var personalAreaModuleCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    
    private var digitalProfileCoordinator: PersonalAreaDigitalProfileCoordinator {
        return dependenciesResolver.resolve()
    }
    
    private var digitalProfileUseCase: DigitalProfileUseCase {
        dependenciesResolver.resolve()
    }
    
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        return self.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private func loadDigitalProfile() {
        UseCaseWrapper(
            with: digitalProfileUseCase,
            useCaseHandler: dependenciesResolver.resolve(),
            onSuccess: { [weak self] response in
                let configured = response.configuredItems.sorted { $0.value() > $1.value() }
                let notConfigured = response.notConfiguredItems.sorted { $0.value() > $1.value() }
                let model = DigitalProfileViewModel(
                    percentage: response.percentage,
                    category: response.category,
                    configuredItems: configured,
                    notConfiguredItems: notConfigured,
                    username: response.username,
                    userLastname: response.userLastname,
                    userImage: response.userImage
                )
                self?.view?.configureView(model: model)
                self?.trackNotConfiguredItems(notConfigured)
            }
        )
    }
    
    private func trackNotConfiguredItems(_ notConfigured: [DigitalProfileElemProtocol]) {
        notConfigured.forEach { (item) in
            trackEvent(.acceder, parameters: [.digitalProfileNotConfigured: item.trackName()])
        }
    }
}

extension DigitalProfilePresenter: DigitalProfilePresenterProtocol {
    func viewDidLoad() {
        getIsSearchEnabled()
        self.trackScreen()
    }
    
    func viewWillAppear() {
        otpPushManager?.updateToken { [weak self] _, _ in
            self?.loadDigitalProfile()
        }
    }
    
    func drawerAction() {
        personalAreaModuleCoordinator?.didSelectMenu()
    }
    
    func backButtonAction() {
        moduleCoordinator?.end()
    }
    
    func searchAction() {
        personalAreaModuleCoordinator?.didSelectSearch()
    }
    
    func didSelect(item: DigitalProfileElemProtocol) {
        if let itemToEnum = DigitalProfileElem(digitalProfileElemProtocol: item) {
            switch itemToEnum {
            case .touchID, .faceID, .geolocalization, .safeDevice:
                digitalProfileCoordinator.goToSecurity()
            case .notificationPermissions:
                digitalProfileCoordinator.goToConfiguration()
            case .email, .phoneNumber, .GDPR, .alias, .profilePicture:
                digitalProfileCoordinator.goToUserBasicInfo()
            case .mobilePayment:
                personalAreaModuleCoordinator?.goToAddToApplePay()
            case .operativity:
                digitalProfileCoordinator.goToSecurity()
            default: break
            }
        } else {
            dependenciesResolver.resolve(forOptionalType: DigitalProfileItemsProviderProtocol.self)?.didSelect(item: item)
        }
        
    }
    
    private func goToSecureDevice() {
        personalAreaModuleCoordinator?.showLoading(completion: { [weak self] in
            self?.dataManager?.getOTPPushDevice({ (device) in
                self?.personalAreaModuleCoordinator?.hideLoading(completion: {
                    self?.moduleCoordinatorNavigator?.goToSecureDevice(device: device)
                })
            }, failure: { (error) in
                self?.personalAreaModuleCoordinator?.hideLoading(completion: {
                    self?.showError(localized(error))
                })
            })
        })
    }
    
    private func showError(_ desc: LocalizedStylableText) {
        personalAreaModuleCoordinator?.showAlertDialog(
            acceptTitle: localized("generic_button_accept"),
            cancelTitle: nil,
            title: nil,
            body: desc,
            acceptAction: nil,
            cancelAction: nil
        )
    }
    
    func didSwipe() {
        self.trackEvent(.swipe, parameters: [:])
    }
    
    func infoAction() {
        trackEvent(.tooltip, parameters: [:])
    }
}

extension DigitalProfilePresenter: GlobalSearchEnabledManagerProtocol {
    private func getIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
}

extension DigitalProfilePresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: DigitalProfilePage {
        return DigitalProfilePage()
    }
}
