//
//  SKRegisteredAnotherDeviceExternalDependenciesResolver.swift
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
import ESCommons

public protocol SKRegisteredAnotherDeviceExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func skRegisteredAnotherDeviceCoordinator() -> BindableCoordinator
    func sKSecondStepOnboardingCoordinator() -> BindableCoordinator
    func resolve() -> SpainCompilationProtocol
    func resolve() -> DependenciesResolver
    func resolve() -> DefaultSKOperativeCoordinator
}

public extension SKRegisteredAnotherDeviceExternalDependenciesResolver {
    func skRegisteredAnotherDeviceCoordinator() -> BindableCoordinator {
        return DefaultSKRegisteredAnotherDeviceCoordinator(dependencies: self, navigationController: resolve())
    }
}
