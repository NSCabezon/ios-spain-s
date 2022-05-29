//  GlobalPositionDependenciesResolver.swift
//  CoreFoundationLib
//
//  Created by Juan Carlos López Robles on 2/1/22.
//

import Foundation
import CoreDomain
import SANLegacyLibrary

public protocol GlobalPositionDependenciesResolver: CoreDependenciesResolver {
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> BSANManagersProvider
    func resolve() -> AppRepositoryProtocol
}

extension GlobalPositionDependenciesResolver {
    public func resolve() -> GlobalPositionDataRepository {
        asShared {
            DefaultGlobalPositionDataRepository(dependencies: self)
        }
    }
}

