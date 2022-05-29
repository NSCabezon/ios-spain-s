//
//  FundsTransactionsFilterCoordinator.swift
//  Funds
//

import UI
import CoreFoundationLib
import CoreDomain
import OpenCombine

public protocol FundsTransactionsFilterCoordinator: BindableCoordinator {
    func dismiss()
}

final class DefaultFundsTransactionsFilterCoordinator: FundsTransactionsFilterCoordinator {
    
    var onFinish: (() -> Void)?
    weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: FundsTransactionsFilterExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: FundsTransactionsFilterExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultFundsTransactionsFilterCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
}

private extension DefaultFundsTransactionsFilterCoordinator {
    struct Dependency: FundsTransactionsFilterDependenciesResolver {
        let dependencies: FundsTransactionsFilterExternalDependenciesResolver
        let coordinator: FundsTransactionsFilterCoordinator
        let dataBinding = DataBindingObject()
        
        var external: FundsTransactionsFilterExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> FundsTransactionsFilterCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
