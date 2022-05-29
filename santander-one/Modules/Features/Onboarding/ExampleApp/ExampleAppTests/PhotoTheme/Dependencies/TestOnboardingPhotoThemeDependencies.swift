//
//  TestOnboardingPhotoThemeDependencies.swift
//  ExampleAppTests
//
//  Created by Jose Camallonga on 17/12/21.
//

import Foundation
import UI
import CoreFoundationLib
@testable import Onboarding

struct TestOnboardingPhotoThemeDependencies: OnboardingPhotoThemeDependenciesResolver {
    let dependencies: OnboardingDependencies
    let external: OnboardingPhotoThemeExternalDependenciesResolver
    let dataBindingObject = DataBindingObject()
    
    init(dependencies: OnboardingDependencies, externalDependencies: OnboardingPhotoThemeExternalDependenciesResolver) {
        self.dependencies = dependencies
        self.external = externalDependencies
    }
    
    func resolve() -> DataBinding {
        return dataBindingObject
    }
    
    func resolve() -> StepsCoordinator<OnboardingStep> {
        return dependencies.resolve()
    }
    
    func resolve() -> OnboardingCoordinator {
        return dependencies.resolve()
    }
}
