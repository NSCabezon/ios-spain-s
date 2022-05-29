//
//  LoanTransactionsSearchCoordinator.swift
//  Loans
//
//  Created by Juan Jose Acosta on 11/3/21.
//
import UI
import CoreFoundationLib
import CoreDomain
import OpenCombine
import Foundation

protocol LoanTransactionSearchCoordinator: BindableCoordinator {
    func dismiss()
}

final class DefaultLoanTransactionSearchCoordinator: LoanTransactionSearchCoordinator {
    
    var onFinish: (() -> Void)?
    weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: LoanTransactionSearchExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: LoanTransactionSearchExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultLoanTransactionSearchCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
}

private extension DefaultLoanTransactionSearchCoordinator {
    struct Dependency: LoanTransactionSearchDependenciesResolver {
        let dependencies: LoanTransactionSearchExternalDependenciesResolver
        let coordinator: LoanTransactionSearchCoordinator
        let dataBinding = DataBindingObject()
        
        var external: LoanTransactionSearchExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> LoanTransactionSearchCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
