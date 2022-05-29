//
//  OnboardingChangeAliasDependencies.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 28/12/21.
//

import Foundation
import UI
import CoreFoundationLib

struct OnboardingChangeAliasDependencies: OnboardingChangeAliasDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingChangeAliasExternalDependenciesResolver {
        return dependencies.external
    }
    
    func resolve() -> DataBinding {
        return dependencies.resolve()
    }
    
    func resolve() -> OnboardingDependencies {
        return dependencies
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
