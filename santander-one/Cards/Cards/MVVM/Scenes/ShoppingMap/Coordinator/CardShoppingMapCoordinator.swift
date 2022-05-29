//  
//  ShoppingMapCoordinator.swift
//  Cards
//
//  Created by Hernán Villamil on 21/2/22.
//

import Foundation
import CoreFoundationLib
import UI

protocol CardShoppingMapCoordinator: BindableCoordinator {}

final class DefaultShoppingMapCoordinator: CardShoppingMapCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: CardShoppingMapExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: CardShoppingMapExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultShoppingMapCoordinator {
    func start() {
        let controller: CardShoppingMapViewController = dependencies.resolve()
        controller.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(controller, animated: true)
    }
}

private extension DefaultShoppingMapCoordinator {
    struct Dependency: CardShoppingMapDependenciesResolver {
        let dependencies: CardShoppingMapExternalDependenciesResolver
        let coordinator: CardShoppingMapCoordinator
        let dataBinding = DataBindingObject()
        
        var external: CardShoppingMapExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> CardShoppingMapCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
