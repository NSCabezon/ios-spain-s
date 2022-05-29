//  
//  SKCustomerDetailsCoordinator.swift
//  SantanderKey
//
//  Created by David Gálvez Alonso on 11/4/22.
//

import Foundation
import CoreFoundationLib
import UI

public protocol SKCustomerDetailsCoordinator: BindableCoordinator {
    func goToSecondStep()
    func goToBiometricsStep()
    func goToOperative()
    func goToMenu()
    func goToSearch()
}

final class DefaultSKCustomerDetailsCoordinator: SKCustomerDetailsCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: SKCustomerDetailsExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: SKCustomerDetailsExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultSKCustomerDetailsCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func goToSecondStep() {
        let secondStepCoordinator = dependencies.external.sKSecondStepOnboardingCoordinator()
        secondStepCoordinator
            .start()
        append(child: secondStepCoordinator)
    }

    func goToBiometricsStep() {
        let biometricsStepCoordinator = dependencies.external.skBiometricsStepOnboardingCoordinator()
        biometricsStepCoordinator
            .start()
        append(child: biometricsStepCoordinator)
    }
    
    func goToOperative() {
        let internalCoordinator: DefaultSKOperativeCoordinator = externalDependencies.resolve()
        internalCoordinator.onFinish = {
            self.goToSecondStep() // TODO: ® Esto hace un pop al FirstStep y seguidamente un push al SecondStep. Queda feo
        }
        internalCoordinator.start()
    }
    
    func goToMenu() {
        let coordinator = externalDependencies.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToSearch() {
        externalDependencies.globalSearchCoordinator().start()
    }
}

private extension DefaultSKCustomerDetailsCoordinator {
    struct Dependency: SKCustomerDetailsDependenciesResolver {
        let dependencies: SKCustomerDetailsExternalDependenciesResolver
        let coordinator: SKCustomerDetailsCoordinator
        let dataBinding = DataBindingObject()
        
        var external: SKCustomerDetailsExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> SKCustomerDetailsCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
