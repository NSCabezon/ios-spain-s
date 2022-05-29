//
//  SKBiometricsDependenciesResolver.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 24/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit
import ESCommons

public protocol SKBiometricsExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol
    func resolve() -> SpainCompilationProtocol
}
