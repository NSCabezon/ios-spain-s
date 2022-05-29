//
//  DefaultPrivateMenuEventsRepositoryDependenciesResolver.swift
//  CoreFoundationLib
//
//  Created by Boris Chirino Fernandez on 24/2/22.
//

import CoreDomain

public protocol PrivateMenuEventsRepositoryDependenciesResolver: CoreDependenciesResolver {
    func resolve() -> PrivateMenuEventsRepository
}

public extension PrivateMenuEventsRepositoryDependenciesResolver {
    func resolve() -> PrivateMenuEventsRepository {
        return asShared {
            DefaultPrivateMenuEventsRepository()
        }
    }
}
