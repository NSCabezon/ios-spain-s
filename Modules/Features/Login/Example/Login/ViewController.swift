import UIKit
import QuickSetup
import Login
import CoreFoundationLib
import SANLibraryV3
import CoreFoundationLib
import UnitTestCommons

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func goToQuickBalance(_ sender: Any) {
        QuickSetup.shared.doLogin(withUser: .demo)
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = LoginModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
        coordinator.start(.quickBalance)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    private lazy var dependenciesResolver: DependenciesResolver = {
        
        let defaultResolver = DependenciesDefault()
        
        defaultResolver.register(for: QuickBalanceCoordinatorProtocol.self) { _ in
            return QuickBalanceCoordinatorImp()
        }
        
        defaultResolver.register(for: BSANManagersProvider.self) { _ in
            return QuickSetup.shared.managersProvider
        }
        
        defaultResolver.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }
        
        defaultResolver.register(for: PullOffersInterpreter.self) { _ in
            return PullOffersInterpreterMock()
        }
        
        defaultResolver.register(for: PfmControllerProtocol.self) { _ in
            return PfmController()
        }
        
        defaultResolver.register(for: GlobalPositionRepresentable.self) { _ in
            return QuickSetup.shared.getGlobalPosition()!
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
        
        defaultResolver.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        
        defaultResolver.register(for: LocalAuthenticationPermissionsManagerProtocol.self) { _ in
            return MockLocalAuthenticationPermissionsManager()
        }
        
        Localized.shared.setup(dependenciesResolver: defaultResolver)
        return defaultResolver
    }()
    
    private lazy var localeManager: LocaleManager = {
        let locale = LocaleManager()
        locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        return locale
    }()
}

final class QuickBalanceCoordinatorImp: QuickBalanceCoordinatorProtocol {
    func didSelectOffer(_ offer: OfferEntity, location: PullOfferLocation) {
        
    }
    
    func didSelectDismiss() {
    }
    func didSelectDeeplink(_ id: String) {
    }
}

class PfmController: PfmControllerProtocol {
    var isFinish: Bool = false
    
    func removePFMSubscriber(_ subscriber: PfmControllerSubscriber) {
        
    }
    
    func isPFMAccountReady(account: AccountEntity) -> Bool {
        return true
    }
    
    func isPFMCardReady(card: CardEntity) -> Bool {
        return true
    }
    
    func registerPFMSubscriber(with subscriber: PfmControllerSubscriber) {
        
    }
}

class PullOffersInterpreterMock: PullOffersInterpreter {
    func disableOffer(identifier: String?) {
        
    }
    
    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool {
        return false
    }
    
    func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]? {
        return nil
    }
    
    func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO? {
        return nil
    }
    
    func getValidOffer(offerId: String) -> OfferDTO? {
        return nil
    }
    
    func getOffer(offerId: String) -> OfferDTO? {
        return nil
    }
    
    func setCandidates(locations: [String: [String]], userId: String, reload: Bool) {
        
    }
    
    func expireOffer(userId: String, offerDTO: OfferDTO) {
        
    }
    
    func removeOffer(location: String) {
        
    }
    
    func reset() {
        
    }
    
    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool {
        return false
    }
}

class MockLocalAuthenticationPermissionsManager: LocalAuthenticationPermissionsManagerProtocol {
    var biometryTypeAvailable: BiometryTypeEntity = .touchId
    
    var isTouchIdEnabled: Bool = true
    
    var deviceToken: String?
    
    var footprint: String?
    
    func enableBiometric() {
        
    }
}
