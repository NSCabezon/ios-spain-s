//
//  FeatureFlagsDependenciesResolver.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol FeatureFlagsDependenciesResolver {
    var external: FeatureFlagsExternalDependenciesResolver { get }
    func resolve() -> FeatureFlagsViewController
    func resolve() -> FeatureFlagsViewModel
    func resolve() -> GetFeatureFlagsUseCase
    func resolve() -> UpdateFeatureFlagUseCase
    func resolve() -> FeatureFlagsCoordinator
}

extension FeatureFlagsDependenciesResolver {
    
    func resolve() -> FeatureFlagsViewController {
        return FeatureFlagsViewController(dependencies: self)
    }
    
    func resolve() -> FeatureFlagsViewModel {
        return FeatureFlagsViewModel(dependencies: self)
    }
    
    func resolve() -> GetFeatureFlagsUseCase {
        return DefaultGetFeatureFlagsUseCase(dependencies: self)
    }
    
    func resolve() -> UpdateFeatureFlagUseCase {
        return DefaultUpdateFeatureFlagUseCase(dependencies: self) 
    }
}
