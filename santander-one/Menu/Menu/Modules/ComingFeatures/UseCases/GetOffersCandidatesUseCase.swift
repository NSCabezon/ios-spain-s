//
//  GetOffersCandidatesUseCase.swift
//  Menu
//
//  Created by Tania Castellano Brasero on 24/03/2020.
//

import Foundation
import CoreFoundationLib

public class GetOffersCandidatesUseCase: UseCase<GetOffersCandidatesUseCaseInput, GetOffersCandidatesUseCaseOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: GetOffersCandidatesUseCaseInput) throws ->
        UseCaseResponse<GetOffersCandidatesUseCaseOutput, StringErrorOutput> {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        
        var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
        if let userId: String = globalPosition.userId {
            for location in requestValues.locations {
                if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                    outputCandidates[location] = OfferEntity(candidate, location: location)
                }
            }
        }
        
        return .ok(GetOffersCandidatesUseCaseOutput(pullOfferCandidates: outputCandidates))
    }
}

public struct GetOffersCandidatesUseCaseInput {
    public let locations: [PullOfferLocation]
    
    public init(locations: [PullOfferLocation]) {
        self.locations = locations
    }
}

public struct GetOffersCandidatesUseCaseOutput {
    public let pullOfferCandidates: [PullOfferLocation: OfferEntity]
}
