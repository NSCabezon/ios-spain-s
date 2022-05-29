import UI
import CoreFoundationLib
import CoreDomain
import CoreTestData
@testable import Menu

struct PublicMenuSceneExternalDependenciesResolverMock: PublicMenuSceneExternalDependenciesResolver {
    func resolve() -> TrackerManager {
        fatalError()
    }
    
    func resolve() -> ReactivePullOffersInterpreter {
        MockReactivePullOffersInterpreter(mockDataInjector: MockDataInjector())
    }
    
    func resolve() -> BaseURLProvider {
        BaseURLProvider(baseURL: "")
    }
    
    func resolve() -> ReactivePullOffersConfigRepository {
        MockReactivePullOffersConfigRepository()
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> PublicMenuActionsRepository {
        PublicMenuActionsRepositoryMock()
    }
    
    func resolveSideMenuNavigationController() -> UINavigationController {
        fatalError()
    }
    
    func publicMenuATMLocatorCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func asShared<Dependency>(_ dependency: () -> Dependency) -> Dependency {
        fatalError()
    }
    
    public func resolve() -> PublicMenuRepository {
        fatalError()
    }
    
    public func publicMenuATMHomeCoordinator() -> Coordinator {
        fatalError()
    }
    
    func publicMenuStockholdersCoordinator() -> Coordinator {
        fatalError()
    }
    
    func publicMenuOurProductsCoordinator() -> Coordinator {
        fatalError()
    }
    
    func publicMenuHomeTipsCoordinator() -> Coordinator {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        fatalError()
    }
    func resolve() -> PublicMenuToggleOutsider {
        fatalError()
    }
    
    func resolve() -> HomeTipsRepository {
        fatalError()
    }
    
    func resolve() -> SegmentedUserRepository {
        fatalError()
    }
}
