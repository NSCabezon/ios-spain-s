//
//  SKSecondStepOnboardingExternalDependenciesResolver.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit
import SANSpainLibrary

public protocol SKSecondStepOnboardingExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func sKSecondStepOnboardingCoordinator() -> BindableCoordinator
    func skBiometricsStepOnboardingCoordinator() -> BindableCoordinator
    func resolve() -> DefaultSKOperativeCoordinator
}

public extension SKSecondStepOnboardingExternalDependenciesResolver {
    func sKSecondStepOnboardingCoordinator() -> BindableCoordinator {
        return DefaultSKSecondStepOnboardingCoordinator(dependencies: self, navigationController: resolve())
    }
}
