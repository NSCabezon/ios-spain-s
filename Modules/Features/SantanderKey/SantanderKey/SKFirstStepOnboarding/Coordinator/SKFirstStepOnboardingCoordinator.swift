//  
//  OnboardingCoordinator.swift
//  Transfer
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import Foundation
import UI
import CoreFoundationLib
import CoreDomain

protocol SKFirstStepOnboardingCoordinator: BindableCoordinator {
    func goToPublicOffer(offer: OfferRepresentable)
    func goToSecondStep()
    func goToOperative()
    func goToBiometricsStep()
}

final class DefaultSKFirstStepOnboardingCoordinator: SKFirstStepOnboardingCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: SKFirstStepOnboardingExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: SKFirstStepOnboardingExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultSKFirstStepOnboardingCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func goToPublicOffer(offer: OfferRepresentable) {
        let coordinator = dependencies.external.resolveOfferCoordinator()
        coordinator
            .set(offer)
            .start()
        append(child: coordinator)
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

    func goToBiometricsStep() { 
        let biometricsStepCoordinator = dependencies.external.skBiometricsStepOnboardingCoordinator()
        biometricsStepCoordinator
            .start()
        append(child: biometricsStepCoordinator)
    }

    func dismiss() { 
        navigationController?.popToRootViewController(animated: false)
    }
}

private extension DefaultSKFirstStepOnboardingCoordinator {
    struct Dependency: SKFirstStepOnboardingDependenciesResolver {
        let dependencies: SKFirstStepOnboardingExternalDependenciesResolver
        let coordinator: SKFirstStepOnboardingCoordinator
        let dataBinding = DataBindingObject()
        
        var external: SKFirstStepOnboardingExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> SKFirstStepOnboardingCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
