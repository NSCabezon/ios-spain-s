//
//  OnboardingConfiguration.swift
//  Onboarding
//
//  Created by Jose Camallonga on 17/1/22.
//

import Foundation
import UI

public protocol OnboardingConfiguration {
    var allowAbort: Bool { get }
    var steps: [StepsCoordinator<OnboardingStep>.Step] { get }
    var countableSteps: [OnboardingStep] { get }
}
