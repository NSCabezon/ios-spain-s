//
//  IncomeXpenseCoordinator.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 09/06/2020.
//

import UI
import CoreFoundationLib

protocol IncomeExpenseCoordinatorProtocol {
    func dismiss()
}

public final class IncomeExpenseCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        guard let controller = self.dependenciesEngine.resolve(for: IncomeExpenseViewProtocol.self) as? UIViewController else { return }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: IncomeExpenseCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: IncomeExpensePresenterProtocol.self) { dependenciesResolver in
            return IncomeExpensePresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: IncomeExpenseViewProtocol.self) { _ in
            let presenter = self.dependenciesEngine.resolve(for: IncomeExpensePresenterProtocol.self)
            let viewController = IncomeExpenseViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension IncomeExpenseCoordinator: IncomeExpenseCoordinatorProtocol {
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
