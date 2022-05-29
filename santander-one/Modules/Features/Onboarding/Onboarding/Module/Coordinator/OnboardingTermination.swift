//
//  OnboardingTermination.swift
//  Onboarding
//
//  Created by Jose Camallonga on 18/1/22.
//

import Foundation
import CoreDomain

public struct OnboardingTermination {
    public let type: OnboardingTerminationType
    public let gpOption: GlobalPositionOptionEntity?
}

public enum OnboardingTerminationType: Equatable {
    case cancelOnboarding(deactivate: Bool)
    case digitalProfile
    case onboardingFinished
}
