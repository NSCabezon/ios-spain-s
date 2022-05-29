//  
//  OneFavouritesListCoordinator.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 4/1/22.
//

import CoreFoundationLib
import UI

protocol OneFavouritesListCoordinator: BindableCoordinator {
    func showHelp()
}

final class DefaultOneFavouritesListCoordinator: OneFavouritesListCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: OneFavouritesListExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: OneFavouritesListExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultOneFavouritesListCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func showHelp() {
        let coordinator = externalDependencies.resolveTransferHelpViewCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
}

private extension DefaultOneFavouritesListCoordinator {
    struct Dependency: OneFavouritesListDependenciesResolver {
        let dependencies: OneFavouritesListExternalDependenciesResolver
        let coordinator: OneFavouritesListCoordinator
        let dataBinding = DataBindingObject()
        
        var external: OneFavouritesListExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> OneFavouritesListCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
