import UI
import Foundation
import CoreDomain
import CoreFoundationLib
import CoreTestData
import OpenCombine
import SANLegacyLibrary

@testable import Cards

struct TestCardTransactionFiltersExternalDependencies: CardTransactionFiltersExternalDependenciesResolver {   
    let globalPositionRepository: MockGlobalPositionDataRepository
    let injector: MockDataInjector

    init(injector: MockDataInjector) {
        self.injector = injector
        self.globalPositionRepository = MockGlobalPositionDataRepository(injector.mockDataProvider.gpData.getGlobalPositionMock)
    }
    
    func resolve() -> NavigationBarItemBuilder {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> StringLoader {
        fatalError()
    }
    
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
}
