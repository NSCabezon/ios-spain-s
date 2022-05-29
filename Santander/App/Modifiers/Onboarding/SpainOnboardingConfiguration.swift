//
//  OnboardingConfiguration.swift
//  Santander
//
//  Created by José Norberto Hidalgo Romero on 7/2/22.
//

import Onboarding
import UI

struct SpainOnboardingConfiguration: OnboardingConfiguration {
    
    let allowAbort = true
    let countableSteps: [OnboardingStep] = [.languages, .options, .selectPG, .photoTheme]
    let steps: [StepsCoordinator<OnboardingStep>.Step] = [StepsCoordinator<OnboardingStep>.Step(type: .welcome),
                                                          StepsCoordinator<OnboardingStep>.Step(type: .changeAlias, state: .disabled),
                                                          StepsCoordinator<OnboardingStep>.Step(type: .languages),
                                                          StepsCoordinator<OnboardingStep>.Step(type: .options),
                                                          StepsCoordinator<OnboardingStep>.Step(type: .selectPG),
                                                          StepsCoordinator<OnboardingStep>.Step(type: .photoTheme),
                                                          StepsCoordinator<OnboardingStep>.Step(type: .final)]
}
