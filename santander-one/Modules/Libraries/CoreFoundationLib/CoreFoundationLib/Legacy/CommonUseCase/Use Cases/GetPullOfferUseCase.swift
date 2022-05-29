//
//  GetPullOfferUseCase.swift
//  CommonUseCase
//
//  Created by Juan Carlos López Robles on 1/15/20.
//

import Foundation

public class GetPullOffersUseCase: UseCase<GetPullOffersUseCaseInput, GetPullOffersUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: GetPullOffersUseCaseInput) throws ->
        UseCaseResponse<GetPullOffersUseCaseOutput, StringErrorOutput> {
            let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
            let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
            var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
            if let userId: String = globalPosition.userId {
                for location in requestValues.locations {
                    if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                        outputCandidates[location] = OfferEntity(candidate, location: location)
                    }
                }
            }
            return .ok(GetPullOffersUseCaseOutput(pullOfferCandidates: outputCandidates))
    }
}

public struct GetPullOffersUseCaseInput {
    public let locations: [PullOfferLocation]
    
    public init(locations: [PullOfferLocation]) {
        self.locations = locations
    }
}

public struct GetPullOffersUseCaseOutput {
    public let pullOfferCandidates: [PullOfferLocation: OfferEntity]
}
