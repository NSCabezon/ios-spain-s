//
//  LoanTransactionsSearchCoordinator.swift
//  Loans
//
//  Created by Rodrigo Jurado on 5/10/21.
//
import UI
import CoreFoundationLib
import CoreDomain
import OpenCombine
import Foundation

protocol OldLoanSearchCoordinator: BindableCoordinator {}

protocol OldDefaultLoanSearchCoordinatorProtocol {
    func didApplyFilter(_ filter: TransactionFiltersEntity, criteria: CriteriaFilter)
    func getFilters() -> TransactionFiltersEntity?
    func dismiss()
}

final class OldDefaultLoanSearchCoordinator: OldLoanSearchCoordinator {
    weak var navigationController: UINavigationController?
    weak var rootViewController: OldLoanSearchViewController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    lazy var dataBinding: DataBinding = dependencies.resolve()
    private let externalDependencies: OldLoanSearchExternalDependenciesResolver

    private lazy var dependencies: Dependency = {
        return Dependency(dependencies: externalDependencies)
    }()
    
    private lazy var legacyDependencies: DependenciesDefault = {
        DependenciesDefault(father: dependencies.external.resolve())
    }()

    init(dependencies: OldLoanSearchExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.externalDependencies = dependencies
        self.navigationController = navigationController
        self.registerDependencies()
    }

    func registerDependencies() {
        self.legacyDependencies.register(for: OldLoanSearchPresenterProtocol.self) { dependenciesResolver in
            return OldLoanSearchPresenter(dependenciesResolver: dependenciesResolver)
        }

        self.legacyDependencies.register(for: OldLoanSearchViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: OldLoanSearchViewController.self)
        }

        self.legacyDependencies.register(for: OldLoanSearchViewController.self) { dependenciesResolver in
            let presenter: OldLoanSearchPresenterProtocol = dependenciesResolver.resolve(for: OldLoanSearchPresenterProtocol.self)
            let viewController = OldLoanSearchViewController(nibName: "OldLoanSearchViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.legacyDependencies.register(for: OldDefaultLoanSearchCoordinatorProtocol.self) { _ in
            return self
        }
    }

    func start() {
         self.navigationController?.blockingPushViewController(legacyDependencies.resolve(for: OldLoanSearchViewController.self), animated: true)
    }
}

extension OldDefaultLoanSearchCoordinator: OldDefaultLoanSearchCoordinatorProtocol {
    
    func didApplyFilter(_ filter: TransactionFiltersEntity, criteria: CriteriaFilter) {
        let filterOutsider: LoanFilterOutsider? = dataBinding.get()
        filterOutsider?.send(filter)
   }

    func getFilters() -> TransactionFiltersEntity? {
        let filters: TransactionFiltersEntity? = dataBinding.get()
        return filters
    }
}

private extension OldDefaultLoanSearchCoordinator {
    struct Dependency: OldLoanSearchDependenciesResolver {
        let dependencies: OldLoanSearchExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        
        var external: OldLoanSearchExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
