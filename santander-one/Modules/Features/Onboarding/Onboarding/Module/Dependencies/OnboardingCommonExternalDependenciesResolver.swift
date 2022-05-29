//
//  OnboardingCommonExternalDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 2/12/21.
//

import Foundation
import CoreDomain
import CoreFoundationLib

public protocol OnboardingCommonExternalDependenciesResolver {
    func resolve() -> LocalAppConfig
    func resolve() -> OnboardingRepository
    func resolve() -> UserPreferencesRepository
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> PersonalAreaRepository
    func resolve() -> LocationPermissionsManagerProtocol
    func resolve() -> CompilationProtocol
    func resolve() -> PushNotificationPermissionsManagerProtocol
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol
    func resolve() -> AppRepositoryProtocol
    func resolve() -> StringLoader
    func resolve() -> TrackerManager
    func resolve() -> DependenciesResolver
    func resolve() -> OnboardingConfiguration
    func resolve() -> OnboardingPermissionOptionsProtocol?
}
