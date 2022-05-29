//
//  TestSKFirstStepOnboardingDependeciesResolver.swift
//  ExampleAppTests
//
//  Created by Ali Ghanbari Dolatshahi on 15/2/22.
//

import UI
import CoreFoundationLib
import Foundation
import CoreTestData
@testable import SantanderKey

struct SKFirstStepOnboardingDependenciesResolverMock: SKFirstStepOnboardingDependenciesResolver {
    let injector: MockDataInjector
    let external: SKFirstStepOnboardingExternalDependenciesResolver
    let coordinator: SKFirstStepOnboardingCoordinatorSpy

    init(injector: MockDataInjector, externalDependencies: SKFirstStepOnboardingExternalDependenciesResolver) {
        self.injector = injector
        self.external = externalDependencies
        self.coordinator = SKFirstStepOnboardingCoordinatorSpy()
    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
    }
    
    func resolve() -> SKFirstStepOnboardingCoordinator {
        return self.coordinator
    }
}
