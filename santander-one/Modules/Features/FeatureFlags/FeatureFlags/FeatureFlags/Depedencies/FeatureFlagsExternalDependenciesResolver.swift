//
//  FeatureFlagsExternalDependenciesResolver.swift
//  FeatureFlags
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit
import UI

public protocol FeatureFlagsExternalDependenciesResolver: FeatureFlagsRepositoryDependenciesResolver, NavigationBarExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> BooleanFeatureFlag
}

extension FeatureFlagsExternalDependenciesResolver {
    
    public func resolve() -> BooleanFeatureFlag {
        return DefaultBooleanFeatureFlag(dependencies: self)
    }
}
