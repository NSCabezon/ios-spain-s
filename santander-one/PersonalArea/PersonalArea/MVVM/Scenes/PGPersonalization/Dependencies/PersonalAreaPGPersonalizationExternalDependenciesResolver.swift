//
//  PersonalAreaPGPersonalizationExternalDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 12/4/22.
//

import Foundation
import CoreFoundationLib
import UI

public protocol PersonalAreaPGPersonalizationExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func personalAreaPGPersonalizationCoordinator() -> Coordinator
}

extension PersonalAreaPGPersonalizationExternalDependenciesResolver {
    public func personalAreaPGPersonalizationCoordinator() -> Coordinator {
        return DefaultPGPersonalizationModuleCoordinator(dependenciesResolver: self, navigationController: resolve())
    }
}
