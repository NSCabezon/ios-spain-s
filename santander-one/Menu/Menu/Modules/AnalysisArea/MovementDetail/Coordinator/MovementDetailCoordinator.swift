//
//  MovementDetailCoordinator.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 24/06/2020.
//

import UI
import CoreFoundationLib

protocol MovementDetailCoordinatorCoordinatorProtocol {
    func dismiss()
    func didSelectMenu()
}

public final class MovementDetailCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        guard let controller = self.dependenciesEngine.resolve(for: MovementDetailViewControllerViewProtocol.self) as? UIViewController else { return }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: MovementDetailCoordinatorCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: MovementDetailPresenterProtocol.self) { dependenciesResolver in
            return MovementDetailPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: MovementDetailViewControllerViewProtocol.self) { _ in
            let presenter = self.dependenciesEngine.resolve(for: MovementDetailPresenterProtocol.self)
            let viewController = MovementDetailViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension MovementDetailCoordinator: MovementDetailCoordinatorCoordinatorProtocol {
    func didSelectMenu() {
        
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
