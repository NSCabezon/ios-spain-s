import CoreFoundationLib
import CoreDomain
import CoreTestData
import UI
@testable import PrivateMenu

extension MockExternalDependencies: PrivateMenuExternalDependenciesResolver {
    func resolve() -> LocationPermissionsManagerProtocol {
        MockLocationPermissionsManager()
    }
    
    func resolve() -> PersonalAreaRepository {
        MockPersonalAreaRepository()
    }
    
    func resolve() -> AppRepositoryProtocol {
        AppRepositoryMock()
    }
    
    func resolve() -> PrivateMenuEventsRepository {
        MockPrivateMenuEventsRepository()
    }
    
    func resolve() -> PrivateMenuToggleOutsider {
        MocKPrivateMenuTogglerOutsider()
    }
    
    func privateSubMenuCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func personalAreaCoordinator() -> BindableCoordinator {
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
    
    func resolve() -> PersonalManagerNotificationReactiveRepository {
        fatalError()
    }
    
    func resolve() -> GetPrivateMenuConfigUseCase {
        DefaultGetPrivateMenuConfigUseCase(dependencies: self)
    }
    
    func resolve() -> GetMyProductsUseCase {
        return DefaultGetMyProductsUseCase(dependencies: self)
    }
    
    func resolve() -> LocalAppConfig {
        return MockLocalAppConfig()
    }
    
    func resolve() -> PersonalManagerReactiveRepository {
        fatalError()
    }
    
    func resolve() -> SegmentedUserRepository {
        return LocalMockSegmentedUserRepository()
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return MockGlobalPositionDataRepository(.init())
    }
    
    func resolve() -> GetCandidateOfferUseCase {
        return DefaultGetCandidateOfferUseCase(dependenciesResolver: self)
    }
    
    func branchLocatorCoordinator() -> BindableCoordinator {
        fatalError()
    }
    func helpCenterCoordinator() -> BindableCoordinator {
        fatalError()
    }
    func resolve() -> UserPreferencesRepository {
        return MockUserPreferencesRepository()
    }
    
    func securityCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func myManagerCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> GetPrivateMenuOptionEnabledUseCase {
        fatalError()
    }
}
