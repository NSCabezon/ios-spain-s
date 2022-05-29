//
//  RetailLegacyPersonalAreaExternalDependenciesResolver.swift
//  RetailLegacy
//
//  Created by alvola on 18/4/22.
//

import Foundation
import UI
import CoreFoundationLib

public protocol RetailLegacyPersonalAreaExternalDependenciesResolver {
    func personalAreaHomeCoordinator() -> Coordinator
    func personalAreaBasicInfoCoordinator() -> Coordinator
    func personalAreaConfigurationCoordinator() -> Coordinator
    func personalAreaDigitalProfileCoordinator() -> Coordinator
    func personalAreaPGPersonalizationCoordinator() -> Coordinator
    func personalAreaSecurityCoordinator() -> BindableCoordinator
    func personalAreaAppPermissionsCoordinator() -> Coordinator
}
