import TransferOperatives
import CoreFoundationLib
import OpenCombine
import CoreDomain
import Operative
import Transfer
import UIKit
import UI

protocol SPInternalTransferLauncherDependenciesResolver: OneTransferHomeExternalDependenciesResolver {
    func resolve() -> OperativeCoordinatorLauncher
    func resolve() -> BooleanFeatureFlag
}

final class SPInternalTransferLauncher {
    private let dependencies: SPInternalTransferLauncherDependenciesResolver
    lazy var dataBinding: DataBinding = DataBindingObject()
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    weak var navigationController: UINavigationController?
    private var subscriptions: Set<AnyCancellable> = []
    
    func start() {
        goToInternalTransfer(account: dataBinding.get())
    }
    
    init(dependencies: SPInternalTransferLauncherDependenciesResolver) {
        self.dependencies = dependencies
    }
}

extension SPInternalTransferLauncher: InternalTransferLauncher {
    func goToInternalTransfer(account: AccountRepresentable?) {
        let booleanFeatureFlag: BooleanFeatureFlag = dependencies.resolve()
        booleanFeatureFlag.fetch(CoreFeatureFlag.internalTransfer)
            .filter { $0 == true }
            .sink { [unowned self] _ in
                let coordinator: InternalTransferOperativeCoordinator = dependencies.resolve()
                if let account = account {
                    coordinator.set(account)
                }
                coordinator.start()
                childCoordinators.append(coordinator)
                coordinator.onFinish = { [weak self] in
                    self?.childCoordinators.removeAll()
                    self?.onFinish?()
                }
            }.store(in: &subscriptions)
        
        booleanFeatureFlag.fetch(CoreFeatureFlag.internalTransfer)
            .filter { $0 == false }
            .sink { [unowned self] _ in
                if let account = account {
                    self.goToLegacyInternalTransfer(account: AccountEntity(account), handler: self)
                } else {
                    self.goToLegacyInternalTransfer(account: nil, handler: self)
                }
            }.store(in: &subscriptions)
    }
}

extension SPInternalTransferLauncher: LegacyInternalTransferLauncher {
    var transferExternalDependencies: OneTransferHomeExternalDependenciesResolver {
        return dependencies
    }
    
    var dependenciesResolver: DependenciesResolver {
        return dependencies.resolve()
    }
}

extension SPInternalTransferLauncher: OperativeLauncherHandler {
    var operativeCoordinatorLauncher: OperativeCoordinatorLauncher {
        return dependencies.resolve()
    }
    
    var operativeNavigationController: UINavigationController? {
        return dependencies.resolve()
    }
    
    func showOperativeLoading(completion: @escaping () -> Void) {
        operativeCoordinatorLauncher.showOperativeLoading(completion: completion)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        operativeCoordinatorLauncher.hideOperativeLoading(completion: completion)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        operativeCoordinatorLauncher.showOperativeAlertError(keyTitle: keyTitle, keyDesc: keyDesc, completion: completion)
    }
}
