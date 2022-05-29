//
//  TestSKSecondStepViewModel.swift
//  ExampleAppTests
//
//  Created by Ali Ghanbari Dolatshahi on 15/2/22.
//

import XCTest
import CoreDomain
import CoreFoundationLib
import OpenCombine
import CoreTestData
import UnitTestCommons
@testable import SantanderKey

class TestSKSecondStepViewModel: XCTestCase {
    lazy var dependencies: SKSecondStepOnboardingDependenciesResolverMock = {
        let external = SKSecondStepOnboardingExternalDependenciesResolverMock()
        return SKSecondStepOnboardingDependenciesResolverMock(injector: self.mockDataInjector, externalDependencies: external)
    }()
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        return injector
    }()
    
    func test_When_didTapOnContinue_Expect_GoToGlobalPositionCalledInCoordinator() throws {
        let sut = SKSecondStepOnboardingViewModel(dependencies: dependencies)
        sut.didSelectOneFloatingButton()
        XCTAssertTrue(self.dependencies.coordinator.goToGlobalPositionCalled)
    }
}
