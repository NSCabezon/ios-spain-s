//
//  PersonalAreaBasicInfoExternalDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 7/4/22.
//

import Foundation
import CoreFoundationLib
import UI

public protocol PersonalAreaBasicInfoExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func personalAreaBasicInfoCoordinator() -> Coordinator
}

extension PersonalAreaBasicInfoExternalDependenciesResolver {
    public func personalAreaBasicInfoCoordinator() -> Coordinator {
        return DefaultBasicInfoModuleCoordinator(dependenciesResolver: self, navigationController: resolve())
    }
}
