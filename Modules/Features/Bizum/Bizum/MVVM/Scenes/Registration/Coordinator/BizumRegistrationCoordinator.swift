//  
//  RegistrationCoordinator.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 11/4/22.
//

import Foundation
import CoreFoundationLib
import UI

protocol BizumRegistrationCoordinator: BindableCoordinator {
    func goToRegistrationOperative()
}

final class BizumDefaultRegistrationCoordinator: BizumRegistrationCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: BizumRegistrationExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: BizumRegistrationExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension BizumDefaultRegistrationCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func goToRegistrationOperative() {
        let internalCoordinator: DefaultBizumRegistrationOperativeCoordinator = externalDependencies.resolve()
        internalCoordinator.start()
    }
}

private extension BizumDefaultRegistrationCoordinator {
    struct Dependency: BizumRegistrationDependenciesResolver {
        let dependencies: BizumRegistrationExternalDependenciesResolver
        let coordinator: BizumRegistrationCoordinator
        let dataBinding = DataBindingObject()
        
        var external: BizumRegistrationExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> BizumRegistrationCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
