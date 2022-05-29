//
//  OnboardingOptionsDependencies.swift
//  Onboarding
//
//  Created by Jose Hidalgo on 07/01/22.
//

import Foundation
import UI
import CoreFoundationLib

struct OnboardingOptionsDependencies: OnboardingOptionsDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingOptionsExternalDependenciesResolver {
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
}
