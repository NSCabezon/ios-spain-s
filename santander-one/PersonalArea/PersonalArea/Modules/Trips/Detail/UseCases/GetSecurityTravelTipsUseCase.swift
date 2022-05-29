//
//  GetSecurityTravelTipsUseCase.swift
//  PersonalArea
//
//  Created by alvola on 02/04/2020.
//

import CoreFoundationLib

final class GetSecurityTravelTipsUseCase: UseCase<Void, GetSecurityTravelTipsUseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSecurityTravelTipsUseOutput, StringErrorOutput> {
        let appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        
        guard let securityTips = try checkRepositoryResponse(appRepository.getSecurityTravelTips()) ?? nil else {
            return .error(StringErrorOutput(nil))
        }
        
        securityTips.forEach {
            $0.offer = containtOffer(forTip: $0)
        }
        
        return .ok(GetSecurityTravelTipsUseOutput(securityTips: securityTips))
    }
    
    private func containtOffer(forTip tip: PullOfferTipEntity) -> OfferEntity? {
        let pullOfferInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        guard let offerId = tip.offerId, let offerDTO = pullOfferInterpreter.getOffer(offerId: offerId) else {
            return nil
        }
        return OfferEntity(offerDTO)
    }
}

struct GetSecurityTravelTipsUseOutput {
    let securityTips: [PullOfferTipEntity]?
}
