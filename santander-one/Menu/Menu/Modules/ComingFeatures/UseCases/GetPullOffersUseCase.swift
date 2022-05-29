//
//  GetPullOffersUseCase.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 02/03/2020.
//

import Foundation
import CoreFoundationLib

class GetPullOffersIdUseCase: UseCase<GetPullOffersIdUseCaseInput, GetPullOffersIdUseCaseOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetPullOffersIdUseCaseInput) throws ->
        UseCaseResponse<GetPullOffersIdUseCaseOutput, StringErrorOutput> {
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let outputCandidates = requestValues.offers.compactMap({ pullOffersInterpreter.getValidOffer(offerId: $0).map(OfferEntity.init) })
        return .ok(GetPullOffersIdUseCaseOutput(pullOfferCandidates: outputCandidates))
    }
}

struct GetPullOffersIdUseCaseInput {
    let offers: [String]
}

struct GetPullOffersIdUseCaseOutput {
    let pullOfferCandidates: [OfferEntity]
}
