//
//  SKBiometricsStepOnboardingExternalDependenciesResolver.swift
//  SantanderKey
//
//  Created by Tania Castellano Brasero on 24/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

public protocol SKBiometricsStepOnboardingExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol
    func resolve() -> CompilationProtocol
    func skBiometricsStepOnboardingCoordinator() -> BindableCoordinator
    func sKSecondStepOnboardingCoordinator() -> BindableCoordinator
}

public extension SKBiometricsStepOnboardingExternalDependenciesResolver {
    func skBiometricsStepOnboardingCoordinator() -> BindableCoordinator {
        return DefaultSKBiometricsStepOnboardingCoordinator(dependencies: self, navigationController: resolve())
    }
}
