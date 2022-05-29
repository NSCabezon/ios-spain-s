//
//  OnboardingExternalDependenciesResolver.swift
//  Transfer
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit
import ESCommons

public protocol SKFirstStepOnboardingExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> GetCandidateOfferUseCase
    func resolve() -> DependenciesResolver
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol
    func resolve() -> DefaultSKOperativeCoordinator
    func resolve() -> SpainCompilationProtocol
    func resolve() -> SantanderKeyTransparentRegisterUseCase
    func resolve() -> SantanderKeyRegisterAuthMethodUseCase
    func skFirstStepOnboardingCoordinator() -> BindableCoordinator
    func resolveOfferCoordinator() -> BindableCoordinator
    func sKSecondStepOnboardingCoordinator() -> BindableCoordinator
    func skBiometricsStepOnboardingCoordinator() -> BindableCoordinator
}

public extension SKFirstStepOnboardingExternalDependenciesResolver {
    func skFirstStepOnboardingCoordinator() -> BindableCoordinator {
        return DefaultSKFirstStepOnboardingCoordinator(dependencies: self, navigationController: resolve())
    }
}
