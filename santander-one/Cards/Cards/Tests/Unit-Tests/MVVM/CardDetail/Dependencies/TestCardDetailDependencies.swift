import Foundation
import CoreTestData
import CoreFoundationLib
@testable import Cards

struct TestCardDetailDependencies: CardDetailDependenciesResolver {
    var external: CardDetailExternalDependenciesResolver
    var dataBinding = DataBindingObject()
    let injector: MockDataInjector
    let mockCoordinator = MockCardDetailCoordinator()
    let mockCardDetailUseCase = MockGetCardDetailUseCase()
    let mockCardDetailConfigurationUseCase = MockGetCardDetailConfigurationUseCase()
    
    init(injector: MockDataInjector, externalDependencies: TestCardDetailExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> CardDetailCoordinator {
        return mockCoordinator
    }
    
    func resolve() -> DataBinding {
        dataBinding
    }
    
    func resolve() -> GetCardDetailConfigurationUseCase {
        return mockCardDetailConfigurationUseCase
    }
    
    func resolve() -> GetCardDetailUseCase {
        return mockCardDetailUseCase
    }
}

