//
//  ExpensesIncomeFilterCoordinator.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 5/7/21.
//

import UI
import CoreFoundationLib

protocol ExpensesIncomeFilterCoordinatorProtocol {
    func dismiss()
}

protocol ExpensesIncomeFilterDelegate: AnyObject {
    func getFilters() -> DetailFilter
    func didApplyFilters(_ filters: DetailFilter)
}

final class ExpensesIncomeFilterCoordinator: ModuleCoordinator {
    var navigationController: UINavigationController?
    let dependenciesEngine: DependenciesDefault
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    func start() {
        let viewController: ExpensesIncomeFilterViewController = dependenciesEngine.resolve()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ExpensesIncomeFilterCoordinator: ExpensesIncomeFilterCoordinatorProtocol {
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}

private extension ExpensesIncomeFilterCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: ExpensesIncomeFilterCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: ExpensesIncomeFilterPresenterProtocol.self) { dependenciesResolver in
            return ExpensesIncomeFilterPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: ExpensesIncomeFilterViewController.self) { dependenciesResolver in
            let presenter: ExpensesIncomeFilterPresenterProtocol = dependenciesResolver.resolve()
            let viewController = ExpensesIncomeFilterViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
