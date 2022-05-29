//
//  OnboardingChangeAliasState.swift
//  Onboarding
//
//  Created by Jose Camallonga on 17/1/22.
//

import Foundation
import CoreFoundationLib

enum OnboardingChangeAliasState: State {
    case idle
    case aliasLoaded(String)
    case navigationItems(_ items: OnboardingChangeAliasStateNavigationItems)
}

struct OnboardingChangeAliasStateNavigationItems {
    let allowAbort: Bool
    let currentPosition: Int?
    let total: Int?
}
