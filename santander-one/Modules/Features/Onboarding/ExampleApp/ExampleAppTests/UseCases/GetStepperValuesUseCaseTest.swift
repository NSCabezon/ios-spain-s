//
//  GetStepperValuesUseCaseTest.swift
//  ExampleAppTests
//
//  Created by Jose Ignacio de Juan Díaz on 17/2/22.
//

import Foundation
import XCTest
import OpenCombine
import CoreTestData
import CoreDomain
import UnitTestCommons
import QuickSetup
import UI
@testable import Onboarding

class GetStepperValuesUseCaseStepper: XCTestCase {
    
    private var useCase: GetStepperValuesUseCase!
    private var externalDependenciesResolver: OnboardingExternalDependenciesResolver!
    private var dependencies: OnboardingOptionsDependenciesResolver!
    private var stepsCoordinator: StepsCoordinator<OnboardingStep>!
    
    override func setUpWithError() throws {
        externalDependenciesResolver = TestOnboardingExternalDependencies()
        dependencies = TestOnboardingOptionsDependencies(dependencies: TestOnboardingDependencies(external: externalDependenciesResolver),
                                                            externalDependencies: externalDependenciesResolver)
        stepsCoordinator = dependencies.resolve()
        useCase = DefaultGetStepperValuesUseCase(stepsCoordinator: stepsCoordinator, onboardingConfiguration: externalDependenciesResolver.resolve())
    }

    override func tearDownWithError() throws {
        externalDependenciesResolver = nil
        dependencies = nil
        stepsCoordinator = nil
    }
    
    func test_getStepperValues_valuesForOptionsStep_success() throws {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        stepsCoordinator.next() // .options
        let publisher = useCase.fetch()
        let values = try publisher.sinkAwait()
        XCTAssertEqual(values.currentPosition, 2)
        XCTAssertEqual(values.totalSteps, 4)
    }
    
}
