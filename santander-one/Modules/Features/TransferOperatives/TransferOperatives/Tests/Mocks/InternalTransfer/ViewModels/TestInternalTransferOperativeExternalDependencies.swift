import TransferOperatives
import CoreFoundationLib
import CoreTestData
import CoreDomain
import Operative
import UI

struct TestInternalTransferOperativeExternalDependencies: InternalTransferOperativeExternalDependenciesResolver {
    var accountRepresentables: [AccountRepresentable]
    
    init(accounts: [AccountRepresentable]) {
        accountRepresentables = accounts
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return TestGlobalPositionDataRepository(accounts: accountRepresentables)
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> AccountNumberFormatterProtocol? {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> InternalTransferAmountModifierProtocol? {
        fatalError()
    }
    
    func resolve() -> CurrencyFormatterProvider {
        fatalError()
    }
    
    func resolve() -> TrackerManager {
        TrackerManagerMock()
    }

    func opinatorCoordinator() -> BindableCoordinator {
        fatalError()
    }

    func resolve() -> TransfersRepository {
        fatalError()
    }

    func resolve() -> BaseURLProvider {
        fatalError()
    }
    
    func resolve() -> OperativeContainerCoordinatorDelegate {
        fatalError()
    }
}
