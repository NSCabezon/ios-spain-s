//  
//  DeleteOtherBankConnectionCoordinator.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 21/3/22.
//

import Foundation
import CoreFoundationLib
import UI

protocol DeleteOtherBankConnectionCoordinator: BindableCoordinator {
    func back()
}

final class DefaultDeleteOtherBankConnectionCoordinator: DeleteOtherBankConnectionCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: DeleteOtherBankConnectionExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: DeleteOtherBankConnectionExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultDeleteOtherBankConnectionCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: !UIAccessibility.isVoiceOverRunning)
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
}

private extension DefaultDeleteOtherBankConnectionCoordinator {
    struct Dependency: DeleteOtherBankConnectionDependenciesResolver {
        
        let dependencies: DeleteOtherBankConnectionExternalDependenciesResolver
        let coordinator: DeleteOtherBankConnectionCoordinator
        let dataBinding = DataBindingObject()
        
        var external: DeleteOtherBankConnectionExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DeleteOtherBankConnectionCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
