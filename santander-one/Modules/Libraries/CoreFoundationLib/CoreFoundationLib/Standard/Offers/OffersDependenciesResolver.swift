//
//  OffersRepository.swift
//  CoreDomain
//
//  Created by José Carlos Estela Anguita on 15/12/21.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol OffersDependenciesResolver: CoreDependenciesResolver {
    func resolve() -> TrackerManager
    func resolve() -> PullOffersPersistenceDataSource
    func resolve() -> ReactivePullOffersRepository
    func resolve() -> DAOPullOffersInfo
    func resolve() -> DAOPullOffersData
    func resolve() -> ReactiveOffersRepository
    func resolve() -> ReactiveRulesRepository
    func resolve() -> GetCandidateOfferUseCase
    func resolve() -> BaseDataSourceParameters
    func resolve() -> ReactivePullOffersConfigRepository
    func resolve() -> PullOffersConfigRepositoryProtocol
    func resolve() -> PullOffersInterpreter
    func resolve() -> ReactivePullOffersInterpreter
    func resolve() -> EngineInterface
    func resolve() -> GlobalPositionDataRepository
}

public extension OffersDependenciesResolver {
    func resolve() -> GetCandidateOfferUseCase {
        return DefaultGetCandidateOfferUseCase(dependenciesResolver: self)
    }
    
    func resolve() -> DAOPullOffersInfo {
        return DAOPullOffersInfoImpl(persistenceDatabaseHelper: PersistenceDatabaseHelper())
    }
    
    func resolve() -> DAOPullOffersData {
        return DAOPullOffersDataImpl()
    }
    
    func resolve() -> PullOffersPersistenceDataSource {
        return LocalPullOffersPersistenceDataSource(daoPullOffersInfo: resolve(), daoPullOffersData: resolve())
    }
    
    func resolve() -> ReactivePullOffersRepository {
        return asShared {
            DefaultPullOffersRepository(pullOffersPersistenceDataSource: resolve())
        }
    }
    
    func resolve() -> ReactiveOffersRepository {
        return asShared {
            OffersRepository(netClient: NetClientImplementation(), assetsClient: AssetsClient(), fileClient: FileClient(), parameters: resolve())
        }
    }
    
    func resolve() -> ReactiveRulesRepository {
        return asShared {
            RulesRepository(netClient: NetClientImplementation(), assetsClient: AssetsClient(), fileClient: FileClient())
        }
    }
    
    func resolve() -> BaseDataSourceParameters {
        return BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "offersV4.xml")
    }
    
    func resolve() -> ReactivePullOffersConfigRepository {
        return DefaultPullOffersConfigRepository(pullOffersConfigRepository: resolve())
    }
    
    func resolve() -> ReactivePullOffersInterpreter {
        return DefaultPullOfferInterpreter(dependenciesResolver: self)
    }
}
