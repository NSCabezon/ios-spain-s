//  
//  CardTransactionFiltersCoordinator.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 19/4/22.
//

import Foundation
import UI
import CoreFoundationLib

protocol CardTransactionFiltersCoordinator: BindableCoordinator {}

final class DefaultCardTransactionFiltersCoordinator: CardTransactionFiltersCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: CardTransactionFiltersExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: CardTransactionFiltersExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultCardTransactionFiltersCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
}

private extension DefaultCardTransactionFiltersCoordinator {
    struct Dependency: CardTransactionFiltersDependenciesResolver {
        let dependencies: CardTransactionFiltersExternalDependenciesResolver
        let coordinator: CardTransactionFiltersCoordinator
        let dataBinding = DataBindingObject()
        
        var external: CardTransactionFiltersExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> CardTransactionFiltersCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
