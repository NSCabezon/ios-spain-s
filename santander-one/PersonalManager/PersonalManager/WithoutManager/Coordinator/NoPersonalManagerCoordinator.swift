//
//  NoPersonalManagerCoordinator.swift
//  PersonalManager
//
//  Created by alvola on 03/02/2020.
//

import CoreFoundationLib
import UI
import SANLegacyLibrary

public protocol NoPersonalManagerCoordinatorDelegate: class {
}

public class NoPersonalManagerCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    weak var coordinator: ModuleSectionInternalCoordinator?
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let noPersonalManagerViewController = self.dependenciesEngine.resolve(for: NoPersonalManagerViewController.self)
        if let globalPositionVC = navigationController?.viewControllers.first {
            navigationController?.setViewControllers([globalPositionVC, noPersonalManagerViewController], animated: true)
        } else {
            navigationController?.setViewControllers([noPersonalManagerViewController], animated: false)
        }
    }
    
    private func setupDependencies() {
    
        self.dependenciesEngine.register(for: NoPersonalManagerPresenterProtocol.self) { dependenciesResolver in
            return NoPersonalManagerPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: NoPersonalManagerViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: NoPersonalManagerViewController.self)
        }
        
        self.dependenciesEngine.register(for: NoPersonalManagerViewController.self) { dependenciesResolver in
            var presenter: NoPersonalManagerPresenterProtocol = dependenciesResolver.resolve(for: NoPersonalManagerPresenterProtocol.self)
            let viewController = NoPersonalManagerViewController(nibName: "NoPersonalManagerViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension NoPersonalManagerCoordinator: ModuleCoordinatorReplacer {
    public func startReplacingCurrent() {
        self.navigationController?.viewControllers.removeLast(1)
        let controller = self.dependenciesEngine.resolve(for: NoPersonalManagerViewController.self)
        self.navigationController?.setViewControllers((self.navigationController?.viewControllers ?? []) + [controller], animated: false)
    }
}
