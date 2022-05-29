//
//  OnboardingWelcomeDependencies.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 28/12/21.
//

import Foundation
import UI
import CoreFoundationLib

struct OnboardingWelcomeDependencies: OnboardingWelcomeDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingWelcomeExternalDependenciesResolver {
        return dependencies.external
    }
    
    func resolve() -> DataBinding {
        return dependencies.resolve()
    }
    
    func resolve() -> OnboardingDependencies {
        return dependencies
    }
    
    func resolve() -> OnboardingCoordinator {
        return dependencies.resolve()
    }
    
    func resolve() -> StepsCoordinator<OnboardingStep> {
        return dependencies.resolve()
    }
    
    func resolve() -> OnboardingLanguageManagerProtocol {
        return dependencies.resolve()
    }
}
