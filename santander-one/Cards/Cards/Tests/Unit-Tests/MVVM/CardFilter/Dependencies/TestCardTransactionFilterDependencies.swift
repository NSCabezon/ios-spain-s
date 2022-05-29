import Foundation
import CoreTestData
import CoreFoundationLib
import UI
@testable import Cards

struct TestCardTransactionFiltersDependencies: CardTransactionFiltersDependenciesResolver {
    var external: CardTransactionFiltersExternalDependenciesResolver
    var dataBinding = DataBindingObject()
    let injector: MockDataInjector
    let mockCardTransactionFiltersUseCase = MockGetCardAvailableFiltersUseCase()
    
    init(injector: MockDataInjector, externalDependencies: TestCardTransactionFiltersExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> DataBinding {
        dataBinding
    }
    
    func resolve() -> CardTransactionFiltersCoordinator {
       fatalError()
    }
    
    func resolve() -> CardTransactionAvailableFiltersUseCase {
        return mockCardTransactionFiltersUseCase
    }
}

