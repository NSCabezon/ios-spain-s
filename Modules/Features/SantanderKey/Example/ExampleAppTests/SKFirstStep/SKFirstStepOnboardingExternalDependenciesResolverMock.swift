//
//  TestSKFirstStepOnboardingExternalDependeciesResolver.swift
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

struct SKFirstStepOnboardingExternalDependenciesResolverMock: SKFirstStepOnboardingExternalDependenciesResolver {

    let getCandidateOfferUseCase : GetCandidateOfferUseCaseSpy
    
    init() {
        self.getCandidateOfferUseCase = GetCandidateOfferUseCaseSpy()
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func sKSecondStepOnboardingCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> GetCandidateOfferUseCase {
        return self.getCandidateOfferUseCase
    }

}
