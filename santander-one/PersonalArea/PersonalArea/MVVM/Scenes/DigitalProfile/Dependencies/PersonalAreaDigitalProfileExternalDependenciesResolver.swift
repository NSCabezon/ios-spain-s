//
//  PersonalAreaDigitalProfileExternalDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 12/4/22.
//

import Foundation
import CoreFoundationLib
import UI

public protocol PersonalAreaDigitalProfileExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> DependenciesResolver
    func personalAreaDigitalProfileCoordinator() -> Coordinator
    func personalAreaBasicInfoCoordinator() -> Coordinator
    func personalAreaConfigurationCoordinator() -> Coordinator
    func personalAreaSecurityCoordinator() -> BindableCoordinator
}

extension PersonalAreaDigitalProfileExternalDependenciesResolver {
    public func personalAreaDigitalProfileCoordinator() -> Coordinator {
        return DefaultDigitalProfileModuleCoordinator(dependenciesResolver: self,
                                                      navigationController: resolve())
    }
}
