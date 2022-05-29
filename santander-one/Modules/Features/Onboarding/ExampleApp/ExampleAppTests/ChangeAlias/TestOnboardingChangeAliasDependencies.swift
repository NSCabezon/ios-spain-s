//
//  TestOnboardingChangeAliasDependencies.swift
//  ExampleAppTests
//
//  Created by Jose Ignacio de Juan Díaz on 30/12/21.
//

import UI
import Foundation
import CoreFoundationLib
@testable import Onboarding

struct TestOnboardingChangeAliasDependencies: OnboardingChangeAliasDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingChangeAliasExternalDependenciesResolver
    
    init(dependencies: OnboardingDependencies, externalDependencies: OnboardingChangeAliasExternalDependenciesResolver) {
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
