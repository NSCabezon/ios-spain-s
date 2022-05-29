//
//  OnboardingFinalExternalDependenciesResolver.swift
//  Onboarding
//
//  Created by José Norberto Hidalgo Romero on 21/12/21.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

public protocol OnboardingFinalExternalDependenciesResolver: OnboardingCommonExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func resolve() -> LocalAppConfig
    func resolve() -> LocationPermissionsManagerProtocol
    func resolve() -> GlobalPositionWithUserPrefsRepresentable
    func resolve() -> PushNotificationPermissionsManagerProtocol
    func resolve() -> AppRepositoryProtocol
    func resolve() -> ApplePayEnrollmentManagerProtocol
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> GetDigitalProfilePercentageUseCase
}

extension OnboardingFinalExternalDependenciesResolver {
    func resolve() -> GetDigitalProfilePercentageUseCase {
        return DefaultGetDigitalProfilePercentageUseCase(dependencies: self)
    }
}
