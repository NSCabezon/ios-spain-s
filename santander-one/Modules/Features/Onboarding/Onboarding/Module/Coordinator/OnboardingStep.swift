//
//  OnboardingStep.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 28/12/21.
//

import Foundation

public enum OnboardingStep: Equatable {
    case welcome
    case changeAlias
    case languages
    case options
    case selectPG
    case photoTheme
    case final
    case custom(identifier: String)
}
