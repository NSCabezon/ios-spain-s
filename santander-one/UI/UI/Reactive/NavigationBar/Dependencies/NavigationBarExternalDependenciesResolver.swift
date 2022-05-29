//
//  NavigationBarExternalDependenciesResolver.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/3/21.
//

import Foundation
import CoreFoundationLib

public protocol NavigationBarExternalDependenciesResolver {
    func resolve() -> AppConfigRepositoryProtocol
    func globalSearchCoordinator() -> Coordinator
    func privateMenuCoordinator() -> Coordinator
}
