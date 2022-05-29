//
//  OnboardingLanguagesExternalDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Camallonga on 9/12/21.
//

import Foundation
import UI
import CoreDomain
import CoreFoundationLib

public protocol OnboardingLanguagesExternalDependenciesResolver: OnboardingCommonExternalDependenciesResolver {
    func resolve() -> AppRepositoryProtocol
    func resolve() -> CoreSessionManager
    func resolve() -> LocalAppConfig
    func resolve() -> PublicFilesManagerProtocol
    func resolve() -> SessionDataManager
    func resolve() -> StringLoader
}
