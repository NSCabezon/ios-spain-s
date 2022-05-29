//
//  TestOnboardingWelcomeDependencies.swift
//  ExampleAppTests
//
//  Created by José Norberto Hidalgo Romero on 7/12/21.
//

import UI
import Foundation
import CoreFoundationLib
@testable import Onboarding

struct TestOnboardingWelcomeDependencies: OnboardingWelcomeDependenciesResolver {
    let dependencies: OnboardingDependencies
    let external: OnboardingWelcomeExternalDependenciesResolver

    init(dependencies: OnboardingDependencies , externalDependencies: OnboardingWelcomeExternalDependenciesResolver) {
        self.dependencies = dependencies
        self.external = externalDependencies
    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
    }
    
    func resolve() -> StepsCoordinator<OnboardingStep> {
        return dependencies.resolve()
    }
    
    func resolve() -> OnboardingCoordinator {
        return dependencies.resolve()
    }
    
    func resolve() -> OnboardingLanguageManagerProtocol {
        return dependencies.resolve()
    }
}
