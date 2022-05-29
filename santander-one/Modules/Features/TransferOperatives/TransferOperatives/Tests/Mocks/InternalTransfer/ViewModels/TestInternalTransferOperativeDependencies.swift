@testable import TransferOperatives
import CoreFoundationLib
import CoreDomain
import UI

final class TestInternalTransferOperativeDependencies: InternalTransferOperativeDependenciesResolver {
    var external: InternalTransferOperativeExternalDependenciesResolver
    var coordinator: InternalTransferOperativeCoordinator!
    private let dataBinding = DataBindingObject()
    
    init(accounts: [AccountRepresentable] = []) {
        self.external = TestInternalTransferOperativeExternalDependencies(accounts: accounts)
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> InternalTransferOperative {
        fatalError()
    }
    
    func resolve() -> InternalTransferOperativeCoordinator {
        return coordinator
    }
    
    func resolve() -> StepsCoordinator<InternalTransferStep> {
        fatalError()
    }
}
