//
//  TestOnboardingOptionsDependencies.swift
//  ExampleAppTests
//
//  Created by Jose Camallonga on 13/1/22.
//

import UI
import Foundation
import CoreFoundationLib
@testable import Onboarding

struct TestOnboardingOptionsDependencies: OnboardingOptionsDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingOptionsExternalDependenciesResolver
    
    init(dependencies: OnboardingDependencies, externalDependencies: OnboardingOptionsExternalDependenciesResolver) {
        self.dependencies = dependencies
        self.external = externalDependencies
    }
    
    func resolve() -> DataBinding {
        return DataBindingObject()
    }
    
    func resolve() -> StepsCoordinator<OnboardingStep> {
        return dependencies.resolve()
    }
    
    func resolve() -> OnboardingCoordinator {
        return dependencies.resolve()
    }
}
