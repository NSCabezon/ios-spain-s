//
//  OnboardingCoordinator.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 28/12/21.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib

public final class OnboardingCoordinator: BindableCoordinator {
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    public weak var navigationController: UINavigationController?
    private let externalDependencies: OnboardingExternalDependenciesResolver
    private lazy var dependencies: OnboardingDependencies = {
        let configuration: OnboardingConfiguration = externalDependencies.resolve()
        let steps = configuration.steps
        let dependencies = Dependencies(external: externalDependencies,
                                        onboardingCoordinator: self,
                                        steps: steps)
        return dependencies
    }()

    public var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    public init(dependencies: OnboardingExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.externalDependencies = dependencies
        self.navigationController = navigationController
    }
    
    public func start() {
        let stepCoordinator: StepsCoordinator<OnboardingStep> = dependencies.resolve()
        stepCoordinator.start()
    }
    
    public func dismiss() {
        self.navigationController?.popToRootViewController(animated: false)
        onFinish?()
    }
    
    final class Dependencies: OnboardingDependencies, DataBindable {
        let external: OnboardingExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        let onboardingCoordinator: OnboardingCoordinator
        let steps: [StepsCoordinator<OnboardingStep>.Step]
        lazy var stepsCoordinator: StepsCoordinator<OnboardingStep> = {
            return StepsCoordinator<OnboardingStep>(navigationController: external.resolve(),
                                                    provider: resolve,
                                                    steps: steps)
        }()
        let languageManager = OnboardingLanguageManager()
        
        init(external: OnboardingExternalDependenciesResolver,
             onboardingCoordinator: OnboardingCoordinator,
             steps: [StepsCoordinator<OnboardingStep>.Step]) {
            self.external = external
            self.onboardingCoordinator = onboardingCoordinator
            self.steps = steps
        }
        
        func resolve() -> OnboardingCoordinator {
            return onboardingCoordinator
        }
        
        func resolve() -> StepsCoordinator<OnboardingStep> {
            return stepsCoordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
        
        func resolve() -> OnboardingLanguageManagerProtocol {
            return languageManager
        }
        
        private func resolve(_ step: OnboardingStep) -> StepIdentifiable {
            switch step {
            case .welcome:
                return resolve() as OnboardingWelcomeViewController
            case .changeAlias:
                return resolve() as OnboardingChangeAliasViewController
            case .languages:
                return resolve() as OnboardingLanguagesViewController
            case .options:
                return resolve() as OnboardingOptionsViewController
            case .selectPG:
                return resolve() as OnboardingGPSelectionViewController
            case .photoTheme:
                return resolve() as OnboardingPhotoThemeViewController
            case .final:
                return resolve() as OnboardingFinalViewController
            case .custom(identifier: let identifier):
                return external.resolveOnBoardingCustomStepView(for: identifier, coordinator: stepsCoordinator)
            }
        }
    }
}
