//
//  OnboardingFinalDependencies.swift
//  Onboarding
//
//  Created by Jose Camallonga on 10/01/22.
//

import Foundation
import UI
import CoreFoundationLib

struct OnboardingFinalDependencies: OnboardingFinalDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingFinalExternalDependenciesResolver {
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
