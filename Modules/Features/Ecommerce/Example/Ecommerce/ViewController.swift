import UIKit
import QuickSetup
import Ecommerce
import CoreFoundationLib
import SANLibraryV3
import SAMKeychain
import ESCommons
import Localization

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentModule()
    }
    
    private func presentModule() {
        QuickSetup.shared.doLogin(withUser: .demo)
        let nav = UINavigationController()
        nav.modalPresentationStyle = .fullScreen
        let coordinator = EcommerceModuleCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: nav
        )
        let controller = FalseLoginViewController(coordinator: coordinator, dependenciesResolver: dependenciesResolver)
        controller.modalPresentationStyle = .fullScreen
        nav.setViewControllers([controller], animated: false)
        self.present(nav, animated: true, completion: nil)
    }
    
    private lazy var dependenciesResolver: DependenciesResolver = {
        
        let defaultResolver = DependenciesDefault()
        
        defaultResolver.register(for: EcommerceMainModuleCoordinatorDelegate.self) { _ in
            return EcommerceMainModuleCoordinatorImp()
        }
        
        defaultResolver.register(for: BSANManagersProvider.self) { _ in
            return QuickSetup.shared.managersProvider
        }
        
        defaultResolver.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }
        
        defaultResolver.register(for: GlobalPositionRepresentable.self) { _ in
            return QuickSetup.shared.getGlobalPosition()!
        }
        defaultResolver.register(for: PullOffersInterpreter.self) { _ in
            return PullOfferInterpreterMock()
        }
        
        defaultResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
            return merger
        }
        
        defaultResolver.register(for: TrackerManager.self) { _ in
            return TrackerManagerMock()
        }
        
        defaultResolver.register(for: TimeManager.self) { _ in
            return self.localeManager
        }
        
        defaultResolver.register(for: StringLoader.self) { _ in
            return self.localeManager
        }
        
        defaultResolver.register(for: SessionConfiguration.self) { _ in
            return SessionConfiguration(timeToExpireSession: 10000000000000,
                                        timeToRefreshToken: 10000000000000,
                                        sessionStartedActions: [],
                                        sessionFinishedActions: [])
        }
        
        defaultResolver.register(for: CompilationProtocol.self) { _ in
            return CompilationMock()
        }
        defaultResolver.register(for: CoreSessionManager.self) { _ in
            return CoreSessionManagerMock(configuration: defaultResolver.resolve(for: SessionConfiguration.self))
        }
        defaultResolver.register(for: AppRepositoryProtocol.self) { _ in
            let appRepository = AppRepositoryMock()
            _ = appRepository.setPersistedUserDTO(
                persistedUserDTO: PersistedUserDTO.createPersistedUser(
                    touchTokenCiphered: nil,
                    loginType: .N,
                    login: "demo",
                    environmentName: "",
                    channelFrame: nil,
                    isPb: true,
                    name: nil,
                    bdpCode: nil,
                    comCode: nil,
                    isSmart: false,
                    userId: "demo",
                    biometryData: nil
                )
            )
            return appRepository
        }
        defaultResolver.register(for: GetLanguagesSelectionUseCaseProtocol.self) { resolver in
            return GetLanguagesSelectionUseCase(dependencies: resolver)
        }
        defaultResolver.register(for: LocalAppConfig.self) { _ in
            return LocalAppConfigMock()
        }
        
        Localized.shared.setup(dependenciesResolver: defaultResolver)
        return defaultResolver
    }()
    
    private lazy var localeManager: LocaleManager = {
        let locale = LocaleManager(dependencies: dependenciesResolver)
        locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        return locale
    }()
    
    private lazy var touchIdData = TouchIdData(deviceMagicPhrase: "",
                                               touchIDLoginEnabled: true,
                                               footprint: "")
}

final class EcommerceMainModuleCoordinatorImp: EcommerceMainModuleCoordinatorDelegate {
    func handleOpinator(_ opinator: OpinatorInfoProtocol) {
        
    }
    
    func didSelectOffer(_ offer: OfferEntity) {
        
    }
    
    func openUrl(_ url: String) {
        
    }
    
    func moreInfo() {
        
    }
    
    func goToNumberPad() {
        
    }
    
    func confirmWithAccessKey(_ code: String) {
        
    }
    
    func dismiss() {
        
    }
}

struct PullOfferInterpreterMock: PullOffersInterpreter {
    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool { return false }
    func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]? { return nil }
    func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO? { return nil }
    func getValidOffer(offerId: String) -> OfferDTO? { return nil }
    func getOffer(offerId: String) -> OfferDTO? { return nil }
    func setCandidates(locations: [String: [String]], userId: String, reload: Bool) {}
    func expireOffer(userId: String, offerDTO: OfferDTO) {}
    func removeOffer(location: String) {}
    func disableOffer(identifier: String?) {}
    func reset() {}
    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool { return false }
}

struct CoreSessionManagerMock: CoreSessionManager {
    var configuration: SessionConfiguration
    var isSessionActive: Bool { true }
    var lastFinishedSessionReason: SessionFinishedReason?
    func setLastFinishedSessionReason(_ reason: SessionFinishedReason) {}
    func sessionStarted(completion: (() -> Void)?) {}
    func finishWithReason(_ reason: SessionFinishedReason) {}
}
