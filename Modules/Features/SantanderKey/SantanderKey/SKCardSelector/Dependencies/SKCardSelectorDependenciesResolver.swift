//
//  SKCardSelectorDependenciesResolver.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 24/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol SKCardSelectorDependenciesResolver {
    var external: SKCardSelectorExternalDependenciesResolver { get }
    func resolve() -> SKCardSelectorViewModel
    func resolve() -> SKCardSelectorViewController
    func resolve() -> SKOperative
    func resolve() -> DataBinding
}

extension SKCardSelectorDependenciesResolver {
    
    func resolve() -> SKCardSelectorViewController {
        return SKCardSelectorViewController(dependencies: self)
    }
    
    func resolve() -> SKCardSelectorViewModel {
        return SKCardSelectorViewModel(dependencies: self)
    }
    
}

struct SKCardSelectorDependency: SKCardSelectorDependenciesResolver {
    let dependencies: SKCardSelectorExternalDependenciesResolver
    let dataBinding: DataBinding
    let coordinator: SKOperativeCoordinator
    let operative: SKOperative
    
    var external: SKCardSelectorExternalDependenciesResolver {
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
