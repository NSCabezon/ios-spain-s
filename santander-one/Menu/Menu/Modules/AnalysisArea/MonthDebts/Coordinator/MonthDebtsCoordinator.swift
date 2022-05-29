//
//  MonthDebtsCoordinator.swift
//  Menu
//
//  Created by Laura González on 05/06/2020.
//

import CoreFoundationLib
import UI

protocol MonthDebtsCoordinatorProtocol {
    func dismiss()
    func showDetailForMovement(_ movements: [TimeLineDebtEntity], selected: Int)
}

public final class MonthDebtsCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let movementDetailCoordinator: MovementDetailCoordinator

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.movementDetailCoordinator = MovementDetailCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController)
        self.setupDependencies()
    }
    
    public func start() {
        guard let controller = self.dependenciesEngine.resolve(for: MonthDebtsViewProtocol.self) as? UIViewController else { return }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: MonthDebtsCoordinatorProtocol.self) {_ in
            return self
        }
        
        self.dependenciesEngine.register(for: MonthDebtsPresenterProtocol.self) { dependenciesResolver in
            return MonthDebtsPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: MonthDebtsViewProtocol.self) { _ in
            let presenter = self.dependenciesEngine.resolve(for: MonthDebtsPresenterProtocol.self)
            let viewController = MonthDebtsViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension MonthDebtsCoordinator: MonthDebtsCoordinatorProtocol {
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showDetailForMovement(_ movements: [TimeLineDebtEntity], selected: Int) {
        self.dependenciesEngine.register(for: MovementDetailConfiguration.self) { _ in
            return MovementDetailConfiguration(debts: movements, selectedIndex: selected)
        }
        movementDetailCoordinator.start()
    }
    
}
