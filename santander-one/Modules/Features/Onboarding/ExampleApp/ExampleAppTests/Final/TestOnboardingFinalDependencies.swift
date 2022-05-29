//
//  TestOnboardingFinalDependencies.swift
//  ExampleAppTests
//
//  Created by Jose Camallonga on 10/1/22.
//

import Foundation
import UI
import CoreFoundationLib
@testable import Onboarding

final class TestOnboardingFinalDependencies: OnboardingFinalDependenciesResolver {
    let dependencies: OnboardingDependencies
    var external: OnboardingFinalExternalDependenciesResolver
    
    init(dependencies: OnboardingDependencies, externalDependencies: OnboardingFinalExternalDependenciesResolver) {
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
