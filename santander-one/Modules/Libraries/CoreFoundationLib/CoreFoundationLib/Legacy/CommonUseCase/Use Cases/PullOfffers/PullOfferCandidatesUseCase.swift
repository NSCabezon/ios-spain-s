//
//  PullOfferCandidatesUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/25/20.
//

import SANLegacyLibrary

public class PullOfferCandidatesUseCase: UseCase<PullOfferCandidatesUseCaseInput, PullOfferCandidatesUseCaseOkOutput, PullOfferCandidatesUseCaseErrorOutput> {
    private let pullOffersInterpreter: PullOffersInterpreter
    private let appRepository: AppRepositoryProtocol
    private let bsanManagersProvider: BSANManagersProvider

    public init(dependenciesResolver: DependenciesResolver) {
        self.pullOffersInterpreter = dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        self.bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appRepository = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
    }
    
    public override func executeUseCase(requestValues: PullOfferCandidatesUseCaseInput) throws -> UseCaseResponse<PullOfferCandidatesUseCaseOkOutput, PullOfferCandidatesUseCaseErrorOutput> {
        let user: String? = try {
            let isSessionEnabled = try appRepository.isSessionEnabled().getResponseData() ?? false
            if !isSessionEnabled {
                return "0"
            } else {
                guard let dto = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition()) else {
                    return nil
                }
                let globalPosition = self.createGlobalPositionFrom(dto: dto)
                return globalPosition.userId
            }
        }()
        guard let userId = user else {
            return UseCaseResponse.error(PullOfferCandidatesUseCaseErrorOutput(nil))
        }
        var outputCandidates = [PullOfferLocation: OfferEntity]()
        for location in requestValues.locations {
            if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                outputCandidates[location] = OfferEntity(candidate, location: location)
            } else {
                outputCandidates[location] = nil
            }
        }
        return UseCaseResponse.ok(PullOfferCandidatesUseCaseOkOutput(candidates: outputCandidates))
    }
}

private extension PullOfferCandidatesUseCase {
    private func createGlobalPositionFrom(dto: GlobalPositionDTO) -> GlobalPositionEntity {
        return GlobalPositionEntity(isPb: nil, dto: dto, cardsData: nil, prepaidCards: nil, cardBalances: nil, temporallyOffCards: nil, inactiveCards: nil, notManagedPortfolios: nil, managedPortfolios: nil, notManagedRVStockAccounts: nil, managedRVStockAccounts: nil)
    }
}

public struct PullOfferCandidatesUseCaseInput {
    public let locations: [PullOfferLocation]
    
    public init(locations: [PullOfferLocation]) {
        self.locations = locations
    }
}

public struct PullOfferCandidatesUseCaseOkOutput {
    public let candidates: [PullOfferLocation: OfferEntity]
    
    public init(candidates: [PullOfferLocation: OfferEntity]) {
        self.candidates = candidates
    }
}

public class PullOfferCandidatesUseCaseErrorOutput: StringErrorOutput {

}
