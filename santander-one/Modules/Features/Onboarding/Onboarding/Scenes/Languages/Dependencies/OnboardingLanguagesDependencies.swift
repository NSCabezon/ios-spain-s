//
//  OnboardingLanguagesDependencies.swift
//  Onboarding
//
//  Created by Jose Camallonga on 7/1/22.
//

import Foundation
import UI
import CoreFoundationLib

struct OnboardingLanguagesDependencies: OnboardingLanguagesDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingLanguagesExternalDependenciesResolver {
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
