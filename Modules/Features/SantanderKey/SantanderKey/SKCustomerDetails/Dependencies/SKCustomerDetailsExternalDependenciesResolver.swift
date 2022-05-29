//
//  SKCustomerDetailsExternalDependenciesResolver.swift
//  SantanderKey
//
//  Created by David Gálvez Alonso on 11/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import UIKit
import SANSpainLibrary
import ESCommons

public protocol SKCustomerDetailsExternalDependenciesResolver: FaqsDependenciesResolver {
    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func resolve() -> SantanderKeyOnboardingRepository
    func resolve() -> SpainCompilationProtocol
    func resolve() -> SKCustomerDetailsCoordinator
    func resolve() -> SantanderKeyTransparentRegisterUseCase
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol
    func resolve() -> DefaultSKOperativeCoordinator
    func sKSecondStepOnboardingCoordinator() -> BindableCoordinator
    func skBiometricsStepOnboardingCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
    func globalSearchCoordinator() -> Coordinator
}

public extension SKCustomerDetailsExternalDependenciesResolver {
    func resolve() -> SKCustomerDetailsCoordinator {
        return DefaultSKCustomerDetailsCoordinator(dependencies: self, navigationController: resolve())
    }
}
