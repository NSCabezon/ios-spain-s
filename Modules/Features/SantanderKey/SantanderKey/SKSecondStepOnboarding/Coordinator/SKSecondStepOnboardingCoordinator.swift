//  
//  SKSecondStepOnboardingCoordinator.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import Foundation
import UI
import CoreFoundationLib
import CoreDomain

protocol SKSecondStepOnboardingCoordinator: BindableCoordinator {
    func goToGlobalPosition()
    func goToSantanderKeyConfiguration()
}

final class DefaultSKSecondStepOnboardingCoordinator: SKSecondStepOnboardingCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: SKSecondStepOnboardingExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: SKSecondStepOnboardingExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultSKSecondStepOnboardingCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func goToGlobalPosition() {
        navigationController?.popToRootViewController(animated: false)
    }
    
    func goToBiometricsStep() {
        let biometricsStepCoordinator = dependencies.external.skBiometricsStepOnboardingCoordinator()
        biometricsStepCoordinator
            .start()
        append(child: biometricsStepCoordinator)
    }
    
    func goToSantanderKeyConfiguration() {
        //TODO: Until this button can work, we're going to start the operative here
        goToSKOperative()
    }

    func goToSKOperative() {
        let skOperativeCoordinator: DefaultSKOperativeCoordinator = dependencies.external.resolve()
        struct SignatureTestDTO: SignatureRepresentable {
            var length: Int? = 8
            var positions: [Int]? = [1, 3, 5, 6]
            var values: [String]? = ["1", "2", "3", "4"]
        }
        let testSignature: SignatureRepresentable = SignatureTestDTO()
        skOperativeCoordinator.set(testSignature)
            .start()
    }
}

private extension DefaultSKSecondStepOnboardingCoordinator {
    struct Dependency: SKSecondStepOnboardingDependenciesResolver {
        let dependencies: SKSecondStepOnboardingExternalDependenciesResolver
        let coordinator: SKSecondStepOnboardingCoordinator
        let dataBinding = DataBindingObject()
        
        var external: SKSecondStepOnboardingExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> SKSecondStepOnboardingCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
