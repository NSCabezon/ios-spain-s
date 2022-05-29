//
//  OnboardingPhotoThemeState.swift
//  Onboarding
//
//  Created by Jose Camallonga on 5/1/22.
//

import Foundation
import CoreFoundationLib

enum OnboardingPhotoThemeState: State {
    case hideLoading(Void)
    case idle
    case info(_ info: OnboardingPhotoThemeStateInfo)
    case navigationItems(_ items: OnboardingPhotoThemeStateNavigationItems)
    case showErrorAlert(_ alert: OnboardingPhotoThemeAlert)
    case showLoading(_ loading: OnboardingPhotoThemeStateLoading)
}

struct OnboardingPhotoThemeStateInfo {
    let info: [PageInfo]
    let titleKey: String
    let currentIndex: Int
    let bannedIndexes: [Int]
}

struct OnboardingPhotoThemeStateLoading {
    let titleKey: String
    let subtitleKey: String
}

struct OnboardingPhotoThemeStateNavigationItems {
    let allowAbort: Bool
    let currentPosition: Int?
    let total: Int?
}

struct OnboardingPhotoThemeAlert {
    let titleKey: String
    let bodyKey: String
    let acceptKey: String
    let acceptAction: (() -> Void)?
}
