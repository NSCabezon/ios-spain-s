import CoreFoundationLib
import CoreDomain
import CoreTestData
@testable import PrivateMenu
import UI

struct TestPrivateMenuExternalDependencies {
    let injector: MockDataInjector
    let globalPositionRepository: MockGlobalPositionDataRepository
    
    init(injector: MockDataInjector) {
        self.injector = injector
        self.globalPositionRepository = MockGlobalPositionDataRepository(injector.mockDataProvider.gpData.getGlobalPositionMock)
    }
}

extension TestPrivateMenuExternalDependencies: PrivateMenuExternalDependenciesResolver {
    func resolve() -> GetPrivateMenuFooterOptionsUseCase {
        return DefaultMenuFooterOptionsUseCase()
    }
    
    func resolve() -> GetCandidateOfferUseCase {
        return DefaultGetCandidateOfferUseCase(dependenciesResolver: self)
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> SegmentedUserRepository {
        return MockSegmentedUserRepository(mockDataInjector: injector)
    }
    
    func resolve() -> LocalAppConfig {
        return MockLocalAppConfig()
    }
    
    func resolve() -> UserPreferencesRepository {
        return MockUserPreferencesRepository()
    }
    
    func resolve() -> PersonalManagerReactiveRepository {
        return MockPersonalManagerReactiveRepository()
    }
    
    func resolve() -> PersonalManagerNotificationReactiveRepository {
        return MockPersonalManagerNotificationReactiveRepository()
    }
    
    func resolve() -> PrivateMenuToggleOutsider {
        fatalError()
    }
    
    func resolve() -> PrivateMenuEventsRepository {
        return MockPrivateMenuEventsRepository()
    }
    
    func resolve() -> AppRepositoryProtocol {
        return AppRepositoryMock()
    }
    
    func resolve() -> PersonalAreaRepository {
        return MockPersonalAreaRepository()
    }
    
    func resolve() -> LocationPermissionsManagerProtocol {
        return MockLocationPermissionsManager()
    }
}

// MARK: - PrivateMenuExternalDependenciesResolver Coordinators

extension TestPrivateMenuExternalDependencies {
    func privateSubMenuCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func personalAreaCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func securityCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func branchLocatorCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func helpCenterCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func myManagerCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func logoutCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func sendMoneyHomeCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func financingHomeCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func billAndTaxesHomeCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func analysisAreaHomeCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func topUpsCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func privateMenuContractViewCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func privateMenuWebConfigurationCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func privateMenuOpinatorCoordinator() -> BindableCoordinator {
        fatalError()
    }
}

extension TestPrivateMenuExternalDependencies: OffersDependenciesResolver {
    func resolve() -> TrackerManager {
        return MockTrackerManager()
    }
    
    func resolve() -> PullOffersConfigRepositoryProtocol {
        return MockPullOffersConfigRepository(mockDataInjector: injector)
    }
    
    func resolve() -> PullOffersInterpreter {
        return MockPullOffersInterpreter()
    }
    
    func resolve() -> EngineInterface {
        return MockEngineInterface()
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return globalPositionRepository
    }
    
    func resolve() -> CoreDependencies {
        return DefaultCoreDependencies()
    }
}
