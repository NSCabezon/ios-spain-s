//  
//  FeatureFlagsCoordinator.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import Foundation
import CoreFoundationLib
import UI

protocol FeatureFlagsCoordinator: BindableCoordinator {}

public final class DefaultFeatureFlagsCoordinator: FeatureFlagsCoordinator {
    public weak var navigationController: UINavigationController?
    private weak var featureFlagsNavigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    private let externalDependencies: FeatureFlagsExternalDependenciesResolver
    public lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: FeatureFlagsExternalDependenciesResolver) {
        self.navigationController = dependencies.resolve()
        self.externalDependencies = dependencies
    }
}

extension DefaultFeatureFlagsCoordinator {
    public func start() {
        let navigationController = UINavigationController(rootViewController: dependencies.resolve())
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true)
        featureFlagsNavigationController = navigationController
    }
    
    public func dismiss() {
        featureFlagsNavigationController?.dismiss(animated: true)
    }
}

private extension DefaultFeatureFlagsCoordinator {
    struct Dependency: FeatureFlagsDependenciesResolver {
        let dependencies: FeatureFlagsExternalDependenciesResolver
        let coordinator: FeatureFlagsCoordinator
        let dataBinding = DataBindingObject()
        
        var external: FeatureFlagsExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> FeatureFlagsCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
