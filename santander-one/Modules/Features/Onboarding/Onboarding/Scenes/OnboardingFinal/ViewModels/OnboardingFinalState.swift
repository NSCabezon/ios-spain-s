//
//  OnboardingFinalState.swift
//  Onboarding
//
//  Created by Jose Camallonga on 17/1/22.
//

import Foundation
import CoreFoundationLib

enum OnboardingFinalState: State {
    case idle
    case digitalProfile(percentage: Double)
    case navigationItems(_ items: OnboardingFinalStateNavigationItems)
    case showLoading(_ loading: OnboardingFinalStateLoading)
    case hideLoading(Void)
}

struct OnboardingFinalStateLoading {
    let titleKey: String
    let subtitleKey: String
}

struct OnboardingFinalStateNavigationItems {
    let allowAbort: Bool
    let currentPosition: Int?
    let total: Int?
}
