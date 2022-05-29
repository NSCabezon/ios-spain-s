//
//  TestSKSecondStepDependeciesResolver.swift
//  ExampleAppTests
//
//  Created by Ali Ghanbari Dolatshahi on 15/2/22.
//

import UI
import CoreFoundationLib
import Foundation
import CoreTestData
@testable import SantanderKey

struct SKSecondStepOnboardingDependenciesResolverMock: SKSecondStepOnboardingDependenciesResolver {
    let injector: MockDataInjector
    let external: SKSecondStepOnboardingExternalDependenciesResolver
    let coordinator: SKSecondStepOnboardingCoordinatorSpy

    init(injector: MockDataInjector, externalDependencies: SKSecondStepOnboardingExternalDependenciesResolver) {
        self.injector = injector
        self.external = externalDependencies
        self.coordinator = SKSecondStepOnboardingCoordinatorSpy()
    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
    }
    
    func resolve() -> SKSecondStepOnboardingCoordinator {
        return self.coordinator
    }
}
