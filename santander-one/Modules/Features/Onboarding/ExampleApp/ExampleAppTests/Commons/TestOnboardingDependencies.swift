//
//  TestOnboardingDependencies.swift
//  ExampleAppTests
//
//  Created by Jose Ignacio de Juan Díaz on 30/12/21.
//

import Foundation
import UI
import CoreFoundationLib
import QuickSetup
@testable import Onboarding

final class TestOnboardingDependencies: OnboardingDependencies, DataBindable {
    lazy var dependenciesResolver: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        return defaultResolver
    }()
    
    let external: OnboardingExternalDependenciesResolver
    let dataBinding: DataBinding = DataBindingObject()
    lazy var stepsCoordinator: StepsCoordinator<OnboardingStep> = {
        let configuration: OnboardingConfiguration = external.resolve()
        return StepsCoordinator<OnboardingStep>(navigationController: external.resolve(),
                                                provider: resolve,
                                                steps: configuration.steps)
    }()
    let languageManager = OnboardingLanguageManager()
    lazy var onboardingCoordinator: OnboardingCoordinator = {
        dependenciesResolver.register(for: OnboardingExternalDependenciesResolver.self) { _ in self.external }
        return OnboardingCoordinator(dependencies: dependenciesResolver)
    }()
    
    init(external: OnboardingExternalDependenciesResolver) {
        self.external = external
    }
    
    func resolve() -> StepsCoordinator<OnboardingStep> {
        return stepsCoordinator
    }
    
    func resolve() -> OnboardingCoordinator {
        return onboardingCoordinator
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
        case .options:
            return resolve() as OnboardingOptionsViewController
        case .selectPG:
            return resolve() as OnboardingGPSelectionViewController
        case .languages:
            return resolve() as OnboardingLanguagesViewController
        case .photoTheme:
            return resolve() as OnboardingPhotoThemeViewController
        case .final:
            return resolve() as OnboardingFinalViewController
        case .custom(identifier: let identifier):
            return external.resolveOnBoardingCustomStepView(for: identifier, coordinator: stepsCoordinator)
        }
    }
}
