import UI
import CoreFoundationLib
import BiometryValidator

protocol BizumConfirmationCoordinatorProtocol {
    func openBiometricValidation(delegate: BiometryValidatorModuleCoordinatorDelegate)
}

final class BizumConfirmationCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: BizumConfirmationViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension BizumConfirmationCoordinator: BizumConfirmationCoordinatorProtocol {
    func openBiometricValidation(delegate: BiometryValidatorModuleCoordinatorDelegate) {
        self.dependenciesEngine.register(for: BiometryValidatorModuleCoordinatorDelegate.self) { _ in
            return delegate
        }
        let coordinator = BiometryValidatorModuleCoordinator(dependenciesResolver: dependenciesEngine, navigationController: self.navigationController)
        coordinator.start()
    }
}
