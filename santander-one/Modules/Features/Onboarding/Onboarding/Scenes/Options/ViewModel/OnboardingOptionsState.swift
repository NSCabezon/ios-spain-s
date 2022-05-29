//
//  OnboardingOptionsState.swift
//  Onboarding
//
//  Created by Jose Camallonga on 12/1/22.
//

import Foundation
import CoreFoundationLib
import UI

enum OnboardingOptionsState: State {
    case idle
    case hideLoading(Void)
    case loadSections(sections: [OnboardingStackSection])
    case navigationItems(_ items: OnboardingOptionsStateNavigationItems)
    case settings(Void)
    case showAlert(_ alert: OnboardingOptionsStateAlert)
    case showLoading(_ loading: OnboardingOptionsStateLoading)
}

struct OnboardingOptionsStateLoading {
    let titleKey: String
    let subtitleKey: String
}

enum OnboardingOptionsStateAlert {
    case common(OnboardingOptionsStateAlertCommon)
    case prompt(OnboardingOptionsStateAlertPrompt)
    case top(OnboardingOptionsStateAlertTop)
}

struct OnboardingOptionsStateAlertCommon {
    let titleKey: String?
    let bodyKey: String
    let acceptKey: String
    let acceptAction: (() -> Void)?
    let cancelKey: String?
    let cancelAction: (() -> Void)?
}

struct OnboardingOptionsStateAlertPrompt {
    let info: PromptDialogInfo
    let identifiers: PromptDialogInfoIdentifiers
    let closeButtonAvailable: Bool
}

struct OnboardingOptionsStateAlertTop {
    let messageKey: String
    let type: OnboardingOptionsStateAlertTopType
    let duration: Double
}

enum OnboardingOptionsStateAlertTopType {
    case info
    case failure
    case message
    
    var toTopAlertType: TopAlertType {
        switch self {
        case .info:
            return .info
        case .failure:
            return .failure
        case .message:
            return .message
        }
    }
}

struct OnboardingOptionsStateNavigationItems {
    let allowAbort: Bool
    let currentPosition: Int?
    let total: Int?
}
