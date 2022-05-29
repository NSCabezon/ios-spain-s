import CoreFoundationLib
import UI
import SANLegacyLibrary
import CoreDomain

public protocol PersonalAreaMainModuleCoordinatorDelegate: LocationPermissionSettingsProtocol {
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectSearch()
    func performAvatarChange(cameraTitle: LocalizedStylableText, cameraRollTitle: LocalizedStylableText, title: LocalizedStylableText?, body: LocalizedStylableText, cameraAction: (() -> Void)?, cameraRollAction: (() -> Void)?)
    func didChangeLanguage(language: Language)
    func globalPositionDidReload()
    func didSelectOffer(offer: OfferRepresentable)
    func showLoading(completion: (() -> Void)?)
    func hideLoading(completion: (() -> Void)?)
    func setTouchIdLoginData(deviceMagicPhrase: String?, touchIDLoginEnabled: Bool?, completion: @escaping (Bool) -> Void)
    func goToSettings()
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?)
    func showPromptDialog(info: PromptDialogInfo, identifiers: PromptDialogInfoIdentifiers, closeButtonEnabled: Bool)
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType)
    func showBiometryMessage(localizedKey: String)
    func performFootprintRegistration(completion: ((Bool) -> Void)?)
    func startGlobalLoading(completion: (() -> Void)?)
    func startCustomLoading(completion: (() -> Void)?)
    func showSecureDeviceOperative()
    func showSecureDeviceOperative(device: OTPPushDeviceEntity?)
    func goToChangePassword()
    func didSelectMultichannelSignature()
    func goToSmartLock()
    func openAppStore()
    func goToAddToApplePay()
}

public final class PersonalAreaMainModuleCoordinator: ModuleCoordinator {
    
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let dataManager: PersonalAreaDataManagerProtocol
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.dataManager = self.dependenciesEngine.resolve(for: PersonalAreaDataManagerProtocol.self)
        self.setupDependencies()
    }
    
    public func start() {
        let personalAreaViewController = dependenciesEngine.resolve(for: PersonalAreaMainModuleViewProtocol.self)
        self.navigationController?.blockingPushViewController(personalAreaViewController, animated: true)
    }
    
    private func setupDependencies() {
        
        self.dependenciesEngine.register(for: PersonalAreaMainModulePresenterProtocol.self) {
            return PersonalAreaMainModulePresenter(dependenciesResolver: $0)
        }
        
        self.dependenciesEngine.register(for: PersonalAreaMainModuleViewProtocol.self) {
            let presenter: PersonalAreaMainModulePresenterProtocol = $0.resolve(for: PersonalAreaMainModulePresenterProtocol.self)
            let viewController = PersonalAreaMainModuleViewController(presenter: presenter, dependenciesResolver: $0)
            presenter.view = viewController
            presenter.dataManager = self.dataManager
            presenter.moduleCoordinatorNavigator = self.dependenciesEngine.resolve(for: PersonalAreaMainModuleNavigator.self)
            return viewController
        }
    }
}
