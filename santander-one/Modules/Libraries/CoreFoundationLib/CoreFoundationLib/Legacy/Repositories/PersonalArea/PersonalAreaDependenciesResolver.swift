//
//  PersonalAreaDependenciesResolver.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 8/2/22.
//

import SANLegacyLibrary

public protocol PersonalAreaDependenciesResolver {
    func resolve() -> GlobalPositionWithUserPrefsRepresentable
    func resolve() -> BSANManagersProvider
    func resolve() -> PushNotificationPermissionsManagerProtocol?
    func resolve() -> LocationPermissionsManagerProtocol?
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol?
    func resolve() -> AppRepositoryProtocol
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> ApplePayEnrollmentManagerProtocol
    func resolve() -> DependenciesResolver
}
