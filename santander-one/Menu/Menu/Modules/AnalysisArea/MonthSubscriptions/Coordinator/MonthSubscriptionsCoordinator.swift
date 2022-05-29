//
//  MonthSubscriptionsCoordinator.swift
//  Menu
//
//  Created by Laura González on 11/06/2020.
//

import UI
import CoreFoundationLib

protocol MonthSubscriptionsCoordinatorProtocol {
    func dismiss()
    func showDetailForMovement(_ movements: [TimeLineSubscriptionEntity], selected: Int)
}

public final class MonthSubscriptionsCoordinator: ModuleCoordinator {
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
        guard let controller = self.dependenciesEngine.resolve(for: MonthSubscriptionsViewProtocol.self) as? UIViewController else { return }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: MonthSubscriptionsCoordinatorProtocol.self) {_ in
            return self
        }
        
        self.dependenciesEngine.register(for: MonthSubscriptionsPresenterProtocol.self) { dependenciesResolver in
            return MonthSubscriptionsPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: MonthSubscriptionsViewProtocol.self) { _ in
            let presenter = self.dependenciesEngine.resolve(for: MonthSubscriptionsPresenterProtocol.self)
            let viewController = MonthSubscriptionsViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension MonthSubscriptionsCoordinator: MonthSubscriptionsCoordinatorProtocol {
    func showDetailForMovement(_ movements: [TimeLineSubscriptionEntity], selected: Int) {
        self.dependenciesEngine.register(for: MovementDetailConfiguration.self) { _ in
            return MovementDetailConfiguration(subscription: movements, selectedIndex: selected)
        }
        movementDetailCoordinator.start()
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
