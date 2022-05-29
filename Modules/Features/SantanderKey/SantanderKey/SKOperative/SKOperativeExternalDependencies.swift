//
//  SKOperativeExternalDependencies.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 22/2/22.
//

import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

public protocol SKOperativeExternalDependenciesResolver: SKDeviceAliasExternalDependenciesResolver & SKCardSelectorExternalDependenciesResolver & SKPinStepExternalDependenciesResolver & SKBiometricsExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func resolve() -> SantanderKeyRegisterValidationWithPositionsUseCase
    func resolve() -> SantanderKeyRegisterConfirmationUseCase
    func resolve() -> SantanderKeyRegisterAuthMethodUseCase
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol
    func resolve() -> LocationPermissionsManagerProtocol
    func resolve() -> SKOperativeCoordinator
}
