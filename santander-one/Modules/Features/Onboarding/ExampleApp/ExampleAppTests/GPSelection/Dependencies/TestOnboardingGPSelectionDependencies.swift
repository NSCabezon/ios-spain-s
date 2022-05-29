//
//  TestOnboardingGPSelectionDependencies.swift
//  ExampleAppTests
//
//  Created by Jose Hidalgo on 14/12/21.
//

import Foundation
import UI
import CoreFoundationLib
@testable import Onboarding

struct TestOnboardingGPSelectionDependencies: OnboardingGPSelectionDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingGPSelectionExternalDependenciesResolver
    let dataBindingObject = DataBindingObject()
    
    init(dependencies: OnboardingDependencies, externalDependencies: OnboardingGPSelectionExternalDependenciesResolver) {
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
    
    func resolve() -> OnboardingLanguageManagerProtocol {
        return dependencies.resolve()
    }
}
