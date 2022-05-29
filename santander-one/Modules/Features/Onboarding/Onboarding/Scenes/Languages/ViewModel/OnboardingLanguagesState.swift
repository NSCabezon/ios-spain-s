//
//  OnboardingLanguagesState.swift
//  Onboarding
//
//  Created by Jose Camallonga on 7/1/22.
//

import Foundation
import CoreFoundationLib

enum OnboardingLanguagesState: State {
    case hideLoading(Void)
    case idle
    case navigationItems(_ items: OnboardingLanguagesStateNavigationItems)
    case reloadContent(Void)
    case showErrorAlert(_ alert: OnboardingLanguagesStateAlert)
    case showLoading(_ loading: OnboardingLanguagesStateLoading)
    case values(_ values: OnboardingLanguagesStateValues)
}

struct OnboardingLanguagesStateLoading {
    let titleKey: String
    let subtitleKey: String
}

struct OnboardingLanguagesStateValues {
    let items: [ValueOptionType]
    let languageSelected: LanguageType?
}

struct OnboardingLanguagesStateNavigationItems {
    let allowAbort: Bool
    let currentPosition: Int?
    let total: Int?
}

enum OnboardingLanguagesStateAlert {
    case common(OnboardingLanguagesStateAlertCommon)
    case generic(Error)
}

struct OnboardingLanguagesStateAlertCommon {
    let bodyKey: String
    let acceptKey: String
}
