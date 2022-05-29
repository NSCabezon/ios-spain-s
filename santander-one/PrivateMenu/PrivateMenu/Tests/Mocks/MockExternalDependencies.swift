import Foundation
import CoreFoundationLib
import CoreDomain
import CoreData
import UI

@testable import PrivateMenu
import CoreTestData

class MockExternalDependencies {
    public var injector: MockDataInjector
    let coreDependencies = DefaultCoreDependencies()
    
    init(injector: MockDataInjector) {
        self.injector = injector
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func resolve() -> MenuRepository {
        return MockMenuRepository()
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
}

extension MockExternalDependencies: CoreDependenciesResolver {
    func resolve() -> CoreDependencies {
        return coreDependencies
    }
}

extension MockExternalDependencies: OffersDependenciesResolver {
    func resolve() -> EngineInterface {
        fatalError()
    }
    
    func resolve() -> PullOffersInterpreter {
        fatalError()
    }
    
    func resolve() -> PullOffersConfigRepositoryProtocol {
        fatalError()
    }
    
    func resolve() -> TrackerManager {
        return MockTrackerManager()
    }
}
