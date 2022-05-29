import UIKit
import QuickSetup
import PersonalArea
import CoreFoundationLib
import UI
import SANLegacyLibrary
import Localization
import CoreTestData
import CoreDomain
import OpenCombine

class ViewController: UIViewController {
    let rootNavigationController = UINavigationController()
    var dependencies: ModuleDependencies!
    
    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    
    private var serviceInjectors: [CustomServiceInjector] {
        return [PersonalAreaServiceInjector()]
    }
    
    private lazy var dependenciesResolver: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: UINavigationController.self) { _ in
            return self.rootNavigationController
        }
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return self.serviceInjectors
        }
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        PersonalAreaDependenciesInitializer(dependencies: defaultResolver, userPreferencesDependencies: MockUserPreferencesDependencies()).registerDependencies()
        return defaultResolver
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dependencies = ModuleDependencies(dependenciesResolver: dependenciesResolver)
        self.servicesProvider.registerDependencies(in: dependenciesResolver)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentModule()
    }
    
    private func presentModule() {
        rootNavigationController.modalPresentationStyle = .fullScreen
        self.present(rootNavigationController, animated: false, completion: {
            self.goToPersonalAreaHome()
        })
        
//        let navigationController = UINavigationController()
//        let coordinator = PersonalAreaModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
//        coordinator.navigationController?.modalPresentationStyle = .fullScreen
//        coordinator.start(.main)
//        if let navController = coordinator.navigationController {
//            self.present(navController, animated: true, completion: nil)
//        }
    }
}

extension ViewController {
    func goToPersonalAreaHome() {
        dependencies
            .personalAreaHomeCoordinator()
            .start()
    }
}

final class ModuleDependencies: PersonalAreaExternalDependenciesResolver,
                                OffersDependenciesResolver,
                                TrackerManagerResolver,
                                GlobalPositionDependenciesResolver, UserPreferencesDependenciesResolver {
    
    var dependenciesResolver: DependenciesInjector & DependenciesResolver
    var coreDependencies = DefaultCoreDependencies()
    var localAppConfig: LocalAppConfig = {
        let local = CoreTestData.LocalAppConfigMock()
        local.isEnabledDigitalProfileView = true
        return local
    }()
    init(dependenciesResolver: DependenciesInjector & DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func resolve() -> GlobalPositionDataRepository {
        asShared {
            return DefaultGlobalPositionDataRepository(dependencies: self)
        }
    }
    
    func resolve() -> AppRepositoryProtocol {
        return AppRepositoryMock()
    }
    
    func resolve() -> LocalAppConfig {
        return self.localAppConfig
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> GetPersonalAreaHomeConfigurationUseCase {
        return GetPersonalAreaHomeConfigurationUseCaseMock()
    }
    
    func resolve() -> GetPersonalAreaHomeFieldsUseCase {
        return GetPersonalAreaHomeFieldsUseCaseMock()
    }
    
    func resolve() -> UINavigationController {
        return dependenciesResolver.resolve(for: UINavigationController.self)
    }
    
    func resolve() -> DependenciesResolver {
        return dependenciesResolver
    }
    
    func globalSearchCoordinator() -> Coordinator {
        return ToastCoordinator("Select Global Search")
    }
    
    func privateMenuCoordinator() -> Coordinator {
        return ToastCoordinator("Select Menu")
    }
    
    func resolve() -> CoreDependencies {
        coreDependencies
    }
    
    func resolve() -> EngineInterface {
        fatalError()
    }
    
    func resolve() -> PullOffersInterpreter {
        fatalError()
    }
    
    func resolve() -> PullOffersConfigRepositoryProtocol {
        fatalError()
    }
    
    func resolve() -> EmmaTrackEventListProtocol {
        return EmmaTrackEventListMock()
    }
    
    func resolve() -> BSANManagersProvider {
        MockBSANManagersProvider.build(from: MockDataInjector())
    }
    
    func personalAreaCustomActionCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func resolve() -> PersonalAreaRepository {
        return MockPersonalAreaRepository()
    }
    
    func resolve() -> GetHomeUserPreferencesUseCase {
        return GetHomeUserPreferencesUseCaseMock()
    }
    
    func resolve() -> NavigationBarItemBuilder {
        return NavigationBarItemBuilder(dependencies: self)
    }
    
    func resolve() -> UserPreferencesRepository {
        UserPreferencesRepositoryMock()
    }
}

public protocol TrackerManagerResolver {
    func resolve() -> TrackerManager
}

public extension TrackerManagerResolver {
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
}

struct MockUserPreferencesRepository: UserPreferencesRepository {
    func getUserPreferences(userId: String) -> AnyPublisher<UserPreferencesRepresentable, Error> {
        Empty().eraseToAnyPublisher()
    }
    
    func updateUserPreferences(update: UpdateUserPreferencesRepresentable) {}
}

struct MockUserPreferencesDependencies: UserPreferencesDependenciesResolver {
    func resolve() -> CoreDependencies {
        DefaultCoreDependencies()
    }
    
    func resolve() -> UserPreferencesRepository {
        MockUserPreferencesRepository()
    }
}
