//
//  CategoriesDetailCoordinator.swift
//  Menu
//
//  Created by David Gálvez Alonso on 29/06/2021.
//

import UI
import CoreFoundationLib

protocol CategoriesDetailCoordinatorProtocol: ModuleCoordinator {
    func dismiss()
    func showExpensesAnalysisConfiguration()
    func didTapOnFilter(filterDelegate: ExpensesIncomeFilterDelegate)
    func showTimePeriodSelector()
}

final class CategoriesDetailCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let movementDetailCoordinator: MovementDetailCoordinator
    private let expensesAnalysisConfigCoordinator: ExpensesAnalysisConfigCoordinator
    private let expensesIncomeFilterCoordinator: ExpensesIncomeFilterCoordinator
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.movementDetailCoordinator = MovementDetailCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController)
        self.expensesAnalysisConfigCoordinator = ExpensesAnalysisConfigCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: self.navigationController)
        self.expensesIncomeFilterCoordinator = ExpensesIncomeFilterCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: self.navigationController)
        self.setupDependencies()
    }
}

extension CategoriesDetailCoordinator: CategoriesDetailCoordinatorProtocol {
    
    func start() {
        guard let controller = self.dependenciesEngine.resolve(for: CategoriesDetailViewProtocol.self) as? UIViewController else { return }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showExpensesAnalysisConfiguration() {
        self.expensesAnalysisConfigCoordinator.start()
    }
    
    func didTapOnFilter(filterDelegate: ExpensesIncomeFilterDelegate) {
        self.dependenciesEngine.register(for: ExpensesIncomeFilterDelegate.self) { _ in
            return filterDelegate
        }
        self.expensesIncomeFilterCoordinator.start()
    }
    
    func showTimePeriodSelector() {
        let controller = self.dependenciesEngine.resolve(for: TimePeriodSelectorViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

private extension CategoriesDetailCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: CategoriesDetailCoordinatorProtocol.self) {_ in
            return self
        }
        self.dependenciesEngine.register(for: CategoriesDetailPresenterProtocol.self) { dependenciesResolver in
            return CategoriesDetailPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: CategoriesDetailViewProtocol.self) { _ in
            let presenter = self.dependenciesEngine.resolve(for: CategoriesDetailPresenterProtocol.self)
            let viewController = CategoriesDetailViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
