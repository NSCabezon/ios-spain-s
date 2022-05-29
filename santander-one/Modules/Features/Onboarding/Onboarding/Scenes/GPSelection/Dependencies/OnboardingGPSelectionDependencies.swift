//
//  OnboardingGPSelectionDependencies.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 5/1/22.
//

import Foundation
import UI
import CoreFoundationLib

struct OnboardingGPSelectionDependencies: OnboardingGPSelectionDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingGPSelectionExternalDependenciesResolver {
        return dependencies.external
    }
    
    func resolve() -> DataBinding {
        return dependencies.resolve()
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
