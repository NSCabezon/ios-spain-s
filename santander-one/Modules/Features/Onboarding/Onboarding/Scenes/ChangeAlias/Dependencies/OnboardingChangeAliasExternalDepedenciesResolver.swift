//
//  OnboardingChangeAliasExternalDepedenciesResolver.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 28/12/21.
//

import Foundation
import CoreFoundationLib

public protocol OnboardingChangeAliasExternalDependenciesResolver: OnboardingCommonExternalDependenciesResolver {
    func resolve() -> TrackerManager
}
