import CoreFoundationLib
import CoreTestData
@testable import Transfer

struct OneTransferHomeDependenciesResolverMock: OneTransferHomeDependenciesResolver {
    var external: OneTransferHomeExternalDependenciesResolver
    var coordinator: OneTransferHomeCoordinator!
    
    func resolve() -> DataBinding {
        return DataBindingObject()
    }
    
    func resolve() -> OneTransferHomeCoordinator {
        return coordinator
    }

    func resolve() -> GetOneFaqsUseCase {
        return GetOneFaqsUseCaseMock()
    }
}
