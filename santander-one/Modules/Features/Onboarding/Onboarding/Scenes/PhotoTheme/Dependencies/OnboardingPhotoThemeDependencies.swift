//
//  OnboardingPhotoThemeDependencies.swift
//  Onboarding
//
//  Created by Jose Camallonga on 5/1/22.
//

import Foundation
import UI
import CoreFoundationLib

struct OnboardingPhotoThemeDependencies: OnboardingPhotoThemeDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingPhotoThemeExternalDependenciesResolver {
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
