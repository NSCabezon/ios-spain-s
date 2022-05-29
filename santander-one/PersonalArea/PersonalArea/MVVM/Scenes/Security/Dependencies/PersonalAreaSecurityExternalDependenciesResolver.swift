//
//  PersonalAreaSecurityExternalDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 11/4/22.
//

import Foundation
import CoreFoundationLib
import UI

public protocol PersonalAreaSecurityExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func personalAreaSecurityCoordinator() -> BindableCoordinator
    func personalAreaSecurityCustomActionCoordinator() -> BindableCoordinator
}

extension PersonalAreaSecurityExternalDependenciesResolver {
    public func personalAreaSecurityCoordinator() -> BindableCoordinator {
        return DefaultSecurityModuleCoordinator(dependenciesResolver: self,
                                                navigationController: resolve())
    }
    public func personalAreaSecurityCustomActionCoordinator() -> BindableCoordinator {
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
}
