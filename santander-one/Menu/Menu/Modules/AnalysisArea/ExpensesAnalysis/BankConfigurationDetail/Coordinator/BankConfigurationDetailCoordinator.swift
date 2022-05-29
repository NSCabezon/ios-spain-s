//
//  BankConfigurationDetailCoordinator.swift
//  Pods
//
//  Created by Francisco del Real Escudero on 2/7/21.
//  

import UI
import CoreFoundationLib

protocol BankConfigurationDetailCoordinatorProtocol {
    func dismiss()
}

final class BankConfigurationDetailCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let viewController = self.dependenciesEngine.resolve(for: BankConfigurationDetailViewController.self)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension BankConfigurationDetailCoordinator: BankConfigurationDetailCoordinatorProtocol {
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}

private extension BankConfigurationDetailCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: BankConfigurationDetailCoordinatorProtocol.self) { _ in
            return self
        }
         
        self.dependenciesEngine.register(for: BankConfigurationDetailPresenterProtocol.self) { resolver in
            return BankConfigurationDetailPresenter(dependenciesResolver: resolver)
        }
         
        self.dependenciesEngine.register(for: BankConfigurationDetailViewController.self) { resolver in
            let presenter = resolver.resolve(for: BankConfigurationDetailPresenterProtocol.self)
            let viewController = BankConfigurationDetailViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: GetConfigurationAccountsUseCase.self) { _ in
            return GetConfigurationAccountsUseCase()
        }
    }
}
