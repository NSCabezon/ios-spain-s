//
//  PersonalAreaConfigurationExternalDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 11/4/22.
//

import Foundation
import CoreFoundationLib
import UI

public protocol PersonalAreaConfigurationExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func personalAreaConfigurationCoordinator() -> Coordinator
    func personalAreaPGPersonalizationCoordinator() -> Coordinator
    func personalAreaAppPermissionsCoordinator() -> Coordinator
}

extension PersonalAreaConfigurationExternalDependenciesResolver {
    public func personalAreaConfigurationCoordinator() -> Coordinator {
        return DefaultConfigurationModuleCoordinator(dependenciesResolver: self,
                                                     navigationController: resolve())
    }
}
