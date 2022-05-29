//
//  SKDeviceAliasDependenciesResolver.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 15/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol SKDeviceAliasDependenciesResolver {
    var external: SKDeviceAliasExternalDependenciesResolver { get }
    func resolve() -> SKDeviceAliasViewController
    func resolve() -> SKDeviceAliasViewModel
    func resolve() -> DataBinding
    func resolve() -> SKOperative
}

extension SKDeviceAliasDependenciesResolver {

    func resolve() -> SKDeviceAliasViewController {
        return SKDeviceAliasViewController(dependencies: self)
    }
    
    func resolve() -> SKDeviceAliasViewModel {
        return SKDeviceAliasViewModel(dependencies: self)
    }
}

struct SKDeviceAliasDependency: SKDeviceAliasDependenciesResolver {
    let dependencies: SKDeviceAliasExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: SKOperativeCoordinator
    let operative: SKOperative
    
    var external: SKDeviceAliasExternalDependenciesResolver {
        return dependencies
    }
    
    func resolve() -> SKOperativeCoordinator {
        return coordinator
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> SKOperative {
        return operative
    }
}
