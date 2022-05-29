//  
//  TimeSelectorCoordinator.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 27/1/22.
//

import Foundation
import UI
import CoreFoundationLib

protocol TimeSelectorCoordinator: BindableCoordinator {
    func close()
}

final class DefaultTimeSelectorCoordinator: TimeSelectorCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: TimeSelectorExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: TimeSelectorExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultTimeSelectorCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: !UIAccessibility.isVoiceOverRunning)
    }
    func close() {
        navigationController?.popViewController(animated: true)
    }
}

private extension DefaultTimeSelectorCoordinator {
    struct Dependency: TimeSelectorDependenciesResolver {
        let dependencies: TimeSelectorExternalDependenciesResolver
        let coordinator: TimeSelectorCoordinator
        let dataBinding = DataBindingObject()
        
        var external: TimeSelectorExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> TimeSelectorCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
