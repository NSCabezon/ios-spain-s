//
//  SKDeviceAliasExternalDependenciesResolver.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 15/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

public protocol SKDeviceAliasExternalDependenciesResolver {
    func resolve() -> UINavigationController
}
