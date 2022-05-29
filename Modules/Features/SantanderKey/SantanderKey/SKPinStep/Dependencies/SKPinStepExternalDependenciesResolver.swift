//
//  SKPinStepExternalDependenciesResolver.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 23/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

public protocol SKPinStepExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> SantanderKeyRegisterValidationWithPINUseCase
    func resolve() -> DependenciesResolver
}
