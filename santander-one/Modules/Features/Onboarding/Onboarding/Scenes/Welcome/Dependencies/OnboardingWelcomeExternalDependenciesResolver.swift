//
//  OnboardingWelcomeExternalDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Camallonga on 30/11/21.
//

import Foundation
import UI
import CoreDomain
import CoreFoundationLib

public protocol OnboardingWelcomeExternalDependenciesResolver: OnboardingCommonExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> TrackerManager
}
