//
//  SKPinStepDependenciesResolver.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 23/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol SKPinStepDependenciesResolver {
    var external: SKPinStepExternalDependenciesResolver { get }
    func resolve() -> SKPinStepViewModel
    func resolve() -> SKPinStepViewController
    func resolve() -> SKOperative
    func resolve() -> DataBinding
}

extension SKPinStepDependenciesResolver {
    
    func resolve() -> SKPinStepViewController {
        return SKPinStepViewController(dependencies: self)
    }
    
    func resolve() -> SKPinStepViewModel {
        return SKPinStepViewModel(dependencies: self)
    }
}

struct SKPinStepDependency: SKPinStepDependenciesResolver {
    let dependencies: SKPinStepExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: SKOperativeCoordinator
    let operative: SKOperative
    
    var external: SKPinStepExternalDependenciesResolver {
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
