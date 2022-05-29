//
//  OnboardingOptionsExternalDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Hidalgo on 07/01/22.
//

import Foundation
import UI
import CoreDomain
import CoreFoundationLib

public protocol OnboardingOptionsExternalDependenciesResolver: OnboardingCommonExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> TrackerManager
}
