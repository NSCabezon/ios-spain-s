//
//  RepositoriesResolver.swift
//  CommonUseCase
//
//  Created by José Carlos Estela Anguita on 28/9/21.
//

import Foundation
import SANLegacyLibrary

public protocol RepositoriesResolvable {
    var dependenciesResolver: DependenciesResolver { get }
    var managersProvider: BSANManagersProvider { get }
    var appRepository: AppRepositoryProtocol { get }
    var appConfigRepository: AppConfigRepositoryProtocol { get }
    var segmentedUserRepository: SegmentedUserRepository { get }
}

extension RepositoriesResolvable {
    public var managersProvider: BSANManagersProvider {
        return dependenciesResolver.resolve()
    }
    public var appRepository: AppRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    public var appConfigRepository: AppConfigRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    public var segmentedUserRepository: SegmentedUserRepository {
        return dependenciesResolver.resolve()
    }
}
