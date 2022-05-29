//
//  OnboardingConfigurationMock.swift
//  ExampleAppTests
//
//  Created by Jose Camallonga on 18/1/22.
//

import Foundation
@testable import Onboarding
import UI

struct OnboardingConfigurationMock: OnboardingConfiguration {

    var allowAbort: Bool {
        return true
    }
    
    var steps: [StepsCoordinator<OnboardingStep>.Step] {
        [StepsCoordinator<OnboardingStep>.Step(type: .welcome),
         StepsCoordinator<OnboardingStep>.Step(type: .changeAlias, state: .disabled),
         StepsCoordinator<OnboardingStep>.Step(type: .languages),
         StepsCoordinator<OnboardingStep>.Step(type: .options),
         StepsCoordinator<OnboardingStep>.Step(type: .selectPG),
         StepsCoordinator<OnboardingStep>.Step(type: .photoTheme),
         StepsCoordinator<OnboardingStep>.Step(type: .final)]
    }
    
    var countableSteps: [OnboardingStep] = [.languages, .options, .selectPG, .photoTheme]
}
