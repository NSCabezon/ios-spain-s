//
//  OnboardingGPSelectionState.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 11/1/22.
//

import Foundation
import CoreFoundationLib

enum OnboardingGPSelectionState: State {
    case idle
    case navigationItems(_ items: OnboardingGPSelectionStateNavigationItems)
    case showInfo(_ info: OnboardingGPSelectionStateInfo)
    case showErrorAlert(_ alert: OnboardingGPSelectionStateAlert)
    case showLoading(_ loading: OnboardingGPSelectionStateLoading)
    case hideLoading(Void)
}

struct OnboardingGPSelectionStateLoading {
    let titleKey: String
    let subtitleKey: String
}

struct OnboardingGPSelectionStateInfo {
    let info: [PageInfo]
    let titleKey: String
    let currentIndex: Int
    let bannedIndexes: [Int]
}

struct OnboardingGPSelectionStateNavigationItems {
    let allowAbort: Bool
    let currentPosition: Int?
    let total: Int?
}

enum OnboardingGPSelectionStateAlert {
    case common(OnboardingGPSelectionStateAlertCommon)
    case generic(Error)
}

struct OnboardingGPSelectionStateAlertCommon {
    let bodyKey: String
    let acceptKey: String
}
