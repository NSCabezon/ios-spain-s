//
//  OnboardingTests.swift
//  SantanderTests
//
//  Created by José Norberto Hidalgo Romero on 17/2/22.
//

import XCTest
import Onboarding
import UI
@testable import Santander

class OnboardingTests: XCTestCase {
    func test_onboardingOptions_success() {
        let options = SpainOnboardingPermissionOptions()
        XCTAssertEqual(options.getOptions(), [.notifications, .location])
    }
    
    func test_onboardingConfiguration_success() {
        let configuration = SpainOnboardingConfiguration()
        XCTAssertTrue(configuration.allowAbort)
        XCTAssertEqual(configuration.countableSteps.count, 4)
        XCTAssertEqual(configuration.steps, [StepsCoordinator<OnboardingStep>.Step(type: .welcome),
                                            StepsCoordinator<OnboardingStep>.Step(type: .changeAlias, state: .disabled),
                                            StepsCoordinator<OnboardingStep>.Step(type: .languages),
                                            StepsCoordinator<OnboardingStep>.Step(type: .options),
                                            StepsCoordinator<OnboardingStep>.Step(type: .selectPG),
                                            StepsCoordinator<OnboardingStep>.Step(type: .photoTheme),
                                            StepsCoordinator<OnboardingStep>.Step(type: .final)])
    }
}
