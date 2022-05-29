//  
//  AnalysisAreaMovementsFilterCoordinator.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 4/4/22.
//

import Foundation
import CoreFoundationLib
import UI
import CoreDomain

protocol AnalysisAreaMovementsFilterCoordinator: BindableCoordinator {
    func back()
}

final class DefaultAnalysisAreaMovementsFilterCoordinator: AnalysisAreaMovementsFilterCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: AnalysisAreaMovementsFilterExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: AnalysisAreaMovementsFilterExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultAnalysisAreaMovementsFilterCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
}

private extension DefaultAnalysisAreaMovementsFilterCoordinator {
    struct Dependency: AnalysisAreaMovementsFilterDependenciesResolver {
        let dependencies: AnalysisAreaMovementsFilterExternalDependenciesResolver
        let coordinator: AnalysisAreaMovementsFilterCoordinator
        let dataBinding = DataBindingObject()
        
        var external: AnalysisAreaMovementsFilterExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> AnalysisAreaMovementsFilterCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
