//
//  OnboardingWelcomeState.swift
//  Onboarding
//
//  Created by Jose Camallonga on 17/1/22.
//

import Foundation
import CoreFoundationLib

enum OnboardingWelcomeState: State {
    case idle
    case navigationItems(_ items: OnboardingWelcomeStateNavigationItems)
    case userInfoLoaded(String)
    case userInfoNotLoaded
}

struct OnboardingWelcomeStateNavigationItems {
    let allowAbort: Bool
    let currentPosition: Int?
    let total: Int?
}
