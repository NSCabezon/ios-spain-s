//
//  CalculateLocationsUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/24/20.
//

import SANLegacyLibrary

public class CalculateLocationsUseCase: UseCase<CalculateLocationsUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let pullOffersInterpreter: PullOffersInterpreter
    private let pullOffersConfigRepository: PullOffersConfigRepositoryProtocol
    private let provider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        self.pullOffersConfigRepository = self.dependenciesResolver.resolve(for: PullOffersConfigRepositoryProtocol.self)
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
    }

    public override func executeUseCase(requestValues: CalculateLocationsUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        
        let user: String? = try {
            let isSessionEnabled = try appRepository.isSessionEnabled().getResponseData() ?? false
            if !isSessionEnabled {
                return "0"
            } else {
                guard let dto = try? checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition()) else {
                    return nil
                }
                let globalPosition = self.createGlobalPositionFrom(dto: dto)
                return globalPosition.userId
            }
        }()
        
        guard let userId = user else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        if let specificLocationsIds = requestValues.specificLocationsIds {
            pullOffersInterpreter.setCandidates(locations: filter(locationsIds: specificLocationsIds), userId: userId, reload: true)
        } else {
            pullOffersInterpreter.reset()
            let specific = PullOffersLocationsFactoryEntity().specificsLocations.map {
                return $0.stringTag
            }
            pullOffersInterpreter.setCandidates(locations: remove(locationsIds: specific), userId: userId, reload: false)
        }
        return UseCaseResponse.ok()
    }
    
    private func filter(locationsIds: [String]) -> [String: [String]] {
        var newLocations: [String: [String]] = [:]
        let locations = pullOffersConfigRepository.getLocations() ?? [:]
        for location in locations.keys where locationsIds.contains(location) {
            newLocations[location] = locations[location]
        }
        return newLocations
    }
    
    private func remove(locationsIds: [String]) -> [String: [String]] {
        var locations = pullOffersConfigRepository.getLocations() ?? [:]
        for location in locations.keys where locationsIds.contains(location) {
            locations[location] = nil
        }
        return locations
    }
    
    private func createGlobalPositionFrom(dto: GlobalPositionDTO) -> GlobalPositionEntity {
        return GlobalPositionEntity(isPb: nil, dto: dto, cardsData: nil, prepaidCards: nil, cardBalances: nil, temporallyOffCards: nil, inactiveCards: nil, notManagedPortfolios: nil, managedPortfolios: nil, notManagedRVStockAccounts: nil, managedRVStockAccounts: nil)
    }
}

public struct CalculateLocationsUseCaseInput {
    let specificLocationsIds: [String]?
    
    public init(specificLocationsIds: [String]? = nil) {
        self.specificLocationsIds = specificLocationsIds
    }
}
