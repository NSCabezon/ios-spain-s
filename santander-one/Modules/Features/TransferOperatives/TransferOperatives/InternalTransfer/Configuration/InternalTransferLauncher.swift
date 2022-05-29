import CoreFoundationLib
import CoreDomain
import Operative
import UIKit
import UI

public protocol InternalTransferLauncherDependenciesResolver {
    func resolve() -> InternalTransferOperativeCoordinator
    func resolve() -> InternalTransferLauncher
}

public extension InternalTransferLauncherDependenciesResolver {
    func resolve() -> InternalTransferLauncher {
        return DefaultInternalTransferLauncher(dependencies: self)
    }
}

public protocol InternalTransferLauncher: BindableCoordinator {}

final class DefaultInternalTransferLauncher: BindableCoordinator {
    private var dependencies: InternalTransferLauncherDependenciesResolver
    lazy var dataBinding: DataBinding = DataBindingObject()
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    weak var navigationController: UINavigationController?
    
    func start() {
        let coordinator: InternalTransferOperativeCoordinator = dependencies.resolve()
        if let account: AccountRepresentable = dataBinding.get() {
            coordinator.set(account)
        }
        coordinator.start()
        childCoordinators.append(coordinator)
        coordinator.onFinish = { [weak self] in
            self?.childCoordinators.removeAll()
            self?.onFinish?()
        }
    }
    
    init(dependencies: InternalTransferLauncherDependenciesResolver) {
        self.dependencies = dependencies
    }
}

extension DefaultInternalTransferLauncher: InternalTransferLauncher {}
