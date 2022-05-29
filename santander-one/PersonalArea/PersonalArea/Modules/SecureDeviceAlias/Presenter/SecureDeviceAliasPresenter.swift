import CoreFoundationLib

protocol SecureDeviceAliasPresenterProtocol: AnyObject {
    var view: SecureDeviceAliasViewProtocol? { get set }
    var moduleCoordinator: SecureDeviceAliasCoordinator? { get set }
    func goToUpdate()
    func viewDidLoad()
    func backDidPressed()
    func closeDidPressed()
}

final class SecureDeviceAliasPresenter {
    weak var view: SecureDeviceAliasViewProtocol?
    weak var moduleCoordinator: SecureDeviceAliasCoordinator?
    private let device: OTPPushDeviceEntity
    private let dependenciesResolver: DependenciesResolver
    private var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return self.dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        let configuration: SecureDeviceAliasConfiguration = dependenciesResolver.resolve()
        self.device = configuration.secureDevice
    }
}

extension SecureDeviceAliasPresenter: SecureDeviceAliasPresenterProtocol {
    func goToUpdate() {
        self.personalAreaCoordinator?.showSecureDeviceOperative(device: self.device)
    }
    
    func viewDidLoad() {
        let model = SecureDeviceAliasViewModel(device: self.device.model,
                                               alias: self.device.alias,
                                               date: self.device.registrationDate)
        self.view?.configureView(model: model)
        self.trackEvent(.actualDevice, parameters: [:])
    }
    
     func backDidPressed() {
        self.moduleCoordinator?.end()
     }
     
     func closeDidPressed() {
         self.moduleCoordinator?.end()
     }

}

extension SecureDeviceAliasPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: SecurityAreaOtpPushPage {
        return SecurityAreaOtpPushPage()
    }
}
