//
//  MonthTransfersCoordinator.swift
//  Menu
//
//  Created by David Gálvez Alonso on 03/06/2020.
//

import UI
import CoreFoundationLib

protocol MonthTransfersCoordinatorProtocol {
    func dismiss()
    func showDetailForMovement(_ movements: [TransferEmittedViewModel], selected: Int)
}

public final class MonthTransfersCoordinator: ModuleCoordinator {
    
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
        guard let controller = self.dependenciesEngine.resolve(for: MonthTransfersViewProtocol.self) as? UIViewController else { return }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: MonthTransfersCoordinatorProtocol.self) {_ in
            return self
        }
        
        self.dependenciesEngine.register(for: MonthTransfersPresenterProtocol.self) { dependenciesResolver in
            return MonthTransfersPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: MonthTransfersViewProtocol.self) { _ in
            let presenter = self.dependenciesEngine.resolve(for: MonthTransfersPresenterProtocol.self)
            let viewController = MonthTransfersViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension MonthTransfersCoordinator: MonthTransfersCoordinatorProtocol {
    func showDetailForMovement(_ movements: [TransferEmittedViewModel], selected: Int) {
        self.dependenciesEngine.register(for: MovementDetailConfiguration.self) { _ in
            return MovementDetailConfiguration(transfers: movements, selectedIndex: selected)
        }
        movementDetailCoordinator.start()
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
