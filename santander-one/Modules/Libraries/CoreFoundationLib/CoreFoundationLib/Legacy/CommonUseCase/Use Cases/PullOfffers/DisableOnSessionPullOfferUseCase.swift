//
//  DisableOnSessionPullOfferUseCase.swift
//  CommonUseCase
//
//  Created by alvola on 11/02/2021.
//

import SANLegacyLibrary

public final class DisableOnSessionPullOfferUseCase: UseCase<DisableOnSessionPullOfferUseCaseInput, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: DisableOnSessionPullOfferUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let pullOffersInterpreter = dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        pullOffersInterpreter.disableOffer(identifier: requestValues.offerId)
        return .ok()
    }
}

public struct DisableOnSessionPullOfferUseCaseInput {
    public let offerId: String
    
    public init(offerId: String) {
        self.offerId = offerId
    }
}
