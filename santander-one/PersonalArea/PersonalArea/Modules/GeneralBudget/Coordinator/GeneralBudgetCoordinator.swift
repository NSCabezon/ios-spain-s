//
//  GeneralBudgetCoordinator.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 01/04/2020.
//

import UI
import CoreFoundationLib

final class GeneralBudgetCoordinator: ModuleCoordinator {

    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let generalBudgetView = dependenciesEngine.resolve(for: GeneralBudgetViewProtocol.self)
        self.navigationController?.blockingPushViewController(generalBudgetView, animated: true)
    }
    
    func end() {
        navigationController?.popViewController(animated: true)
    }
}

private extension GeneralBudgetCoordinator {
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: GeneralBudgetPresenterProtocol.self) { dependenciesResolver in
            return GeneralBudgetPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GeneralBudgetViewProtocol.self) { dependenciesResolver in
            var presenter = dependenciesResolver.resolve(for: GeneralBudgetPresenterProtocol.self)
            let viewController = GeneralBudgetViewController(nibName: "GeneralBudgetViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            presenter.moduleCoordinator = self
            return viewController
        }
    }
}
