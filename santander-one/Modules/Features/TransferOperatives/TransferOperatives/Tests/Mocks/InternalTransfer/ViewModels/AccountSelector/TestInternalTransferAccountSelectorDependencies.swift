@testable import TransferOperatives
import CoreFoundationLib

struct TestInternalTransferAccountSelectorDependencies: InternalTransferAccountSelectorDependenciesResolver {
    private let dataBinding = DataBindingObject()
    private let operativeCoordinator: InternalTransferOperativeCoordinator
    var external: InternalTransferAccountSelectorExternalDependenciesResolver

    init(externalDependencies: TestInternalTransferAccountSelectorExternalDependencies, operativeCoordinator: InternalTransferOperativeCoordinator) {
        self.external = externalDependencies
        self.operativeCoordinator = operativeCoordinator
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> InternalTransferOperative {
        fatalError()
    }
    
    func resolve() -> InternalTransferAccountSelectorViewModel {
        fatalError()
    }
    
    func resolve() -> InternalTransferAccountSelectorViewController {
        fatalError()
    }
    
    func resolve() -> InternalTransferOperativeCoordinator {
        return operativeCoordinator
    }
}
