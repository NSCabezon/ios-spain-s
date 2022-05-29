//  
//  SKRegisteredAnotherDeviceCoordinator.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import Foundation
import UI
import CoreFoundationLib

protocol SKRegisteredAnotherDeviceCoordinator: BindableCoordinator {
    func goToGlobalPosition()
    func goToSecondStep()
    func goToOperative()
}

final class DefaultSKRegisteredAnotherDeviceCoordinator: SKRegisteredAnotherDeviceCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: SKRegisteredAnotherDeviceExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: SKRegisteredAnotherDeviceExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultSKRegisteredAnotherDeviceCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func goToGlobalPosition() {
        navigationController?.popToRootViewController(animated: false) 
    }
    
    func goToSecondStep() {
        let secondStepCoordinator = dependencies.external.sKSecondStepOnboardingCoordinator()
        secondStepCoordinator
            .start()
        append(child: secondStepCoordinator)
    }

    func goToOperative() {
        let internalCoordinator: DefaultSKOperativeCoordinator = externalDependencies.resolve()
        internalCoordinator.onFinish = {
            self.goToSecondStep() // TODO: ® Esto hace un pop al FirstStep y seguidamente un push al SecondStep. Queda feo
        }
        internalCoordinator.start()
    }
}

private extension DefaultSKRegisteredAnotherDeviceCoordinator {
    struct Dependency: SKRegisteredAnotherDeviceDependenciesResolver {
        let dependencies: SKRegisteredAnotherDeviceExternalDependenciesResolver
        let coordinator: SKRegisteredAnotherDeviceCoordinator
        let dataBinding = DataBindingObject()
        
        var external: SKRegisteredAnotherDeviceExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> SKRegisteredAnotherDeviceCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
