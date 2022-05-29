//
//  GetFinanceableCommercialOffersUseCase.swift
//  Models
//
//  Created by Ignacio González Miró on 22/12/21.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public final class GetFinanceableCommercialOffersUseCase: UseCase<Void, GetFinanceableCommercialOffersUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFinanceableCommercialOffersUseCaseOkOutput, StringErrorOutput> {
        let pullOffersConfigRepository = dependenciesResolver.resolve(for: PullOffersConfigRepositoryProtocol.self)
        guard let commercialOffers = pullOffersConfigRepository.getFinancingCommercialOffers() else {
            return .error(StringErrorOutput(nil))
        }
        let entity = PullOffersFinanceableCommercialOfferEntity(commercialOffers)
        return .ok(GetFinanceableCommercialOffersUseCaseOkOutput(commercialOfferEntity: entity))
    }
}

public struct GetFinanceableCommercialOffersUseCaseOkOutput {
    let commercialOfferEntity: PullOffersFinanceableCommercialOfferEntity
}
