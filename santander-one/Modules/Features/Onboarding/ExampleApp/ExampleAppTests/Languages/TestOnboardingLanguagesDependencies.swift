//
//  TestOnboardingLanguagesDependencies.swift
//  ExampleAppTests
//
//  Created by Jose Camallonga on 14/12/21.
//

import UI
import Foundation
import CoreFoundationLib
@testable import Onboarding

struct TestOnboardingLanguagesDependencies: OnboardingLanguagesDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingLanguagesExternalDependenciesResolver
    
    init(dependencies: OnboardingDependencies , externalDependencies: OnboardingLanguagesExternalDependenciesResolver) {
        self.dependencies = dependencies
        self.external = externalDependencies
    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
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
