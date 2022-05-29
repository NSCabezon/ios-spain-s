//
//  ExpirePullOfferUseCase.swift
//  CommonUseCase
//
//  Created by Cristobal Ramos Laina on 30/04/2020.
//

import Foundation
import SANLegacyLibrary

 public class ExpirePullOfferUseCase: UseCase<ExpirePullOfferUseCaseInput, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: ExpirePullOfferUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let offerId = requestValues.offerId
        guard let userId = globalPosition.userId, let offer = pullOffersInterpreter.getOffer(offerId: offerId) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        pullOffersInterpreter.expireOffer(userId: userId, offerDTO: offer)
        
        return UseCaseResponse.ok()
    }
}

 public struct ExpirePullOfferUseCaseInput {
    public let offerId: String
    
    public init(offerId: String) {
        self.offerId = offerId
    }
}
