@testable import TransferOperatives
import CoreFoundationLib

struct TestInternalTransferDestinationAccountDependencies: InternalTransferDestinationAccountDependenciesResolver {
    private let dataBinding = DataBindingObject()
    var external: InternalTransferDestinationAccountExternalDependenciesResolver

    init(externalDependencies: InternalTransferDestinationAccountExternalDependenciesResolver) {
        external = externalDependencies
    }

    func resolve() -> DataBinding {
        return dataBinding
    }

    func resolve() -> InternalTransferOperative {
        fatalError()
    }

    func resolve() -> InternalTransferDestinationAccountViewModel {
        fatalError()
    }

    func resolve() -> InternalTransferDestinationAccountViewController {
        fatalError()
    }

    func resolve() -> InternalTransferOperativeCoordinator {
        fatalError()
    }
}
