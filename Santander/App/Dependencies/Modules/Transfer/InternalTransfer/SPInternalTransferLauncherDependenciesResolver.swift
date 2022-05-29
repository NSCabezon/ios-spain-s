import TransferOperatives
import CoreFoundationLib
import Operative
import UI

extension ModuleDependencies: SPInternalTransferLauncherDependenciesResolver {
    func opinatorCoordinator() -> BindableCoordinator {
        return OpinatorWebViewCoordinator(dependencies: self)
    }
    
    func resolve() -> AccountNumberFormatterProtocol? {
        return nil
    }
    
    func resolve() -> InternalTransferAmountModifierProtocol? {
        return nil
    }
    
    func resolve() -> OperativeCoordinatorLauncher {
        return oldResolver.resolve()
    }
    
    func resolve() -> InternalTransferLauncher {
        return SPInternalTransferLauncher(dependencies: self)
    }
}
