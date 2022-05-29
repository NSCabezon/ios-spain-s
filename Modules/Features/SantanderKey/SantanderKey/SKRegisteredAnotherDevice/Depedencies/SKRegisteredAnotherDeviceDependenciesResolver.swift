//
//  SKRegisteredAnotherDeviceDependenciesResolver.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol SKRegisteredAnotherDeviceDependenciesResolver {
    var external: SKRegisteredAnotherDeviceExternalDependenciesResolver { get }
    func resolve() -> SKRegisteredAnotherDeviceViewModel
    func resolve() -> SKRegisteredAnotherDeviceViewController
    func resolve() -> SKRegisteredAnotherDeviceCoordinator
    func resolve() -> DataBinding
}

extension SKRegisteredAnotherDeviceDependenciesResolver {
    
    func resolve() -> SKRegisteredAnotherDeviceViewController {
        return SKRegisteredAnotherDeviceViewController(dependencies: self)
    }
    
    func resolve() -> SKRegisteredAnotherDeviceViewModel {
        return SKRegisteredAnotherDeviceViewModel(dependencies: self)
    }
}
