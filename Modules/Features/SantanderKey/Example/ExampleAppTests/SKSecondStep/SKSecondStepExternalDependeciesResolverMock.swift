//
//  TestSKSecondStepExternalDependeciesResolver.swift
//  ExampleAppTests
//
//  Created by Ali Ghanbari Dolatshahi on 15/2/22.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain
import QuickSetup
import CoreTestData
import CoreFoundationLib
@testable import SantanderKey

struct SKSecondStepOnboardingExternalDependenciesResolverMock: SKSecondStepOnboardingExternalDependenciesResolver {

    func sKSecondStepOnboardingCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }

}
