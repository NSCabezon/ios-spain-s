//
//  GetSecurityTipsUseCase.swift
//  PersonalArea
//
//  Created by Juan Carlos López Robles on 1/31/20.
//

import CoreFoundationLib
import Foundation

final class GetSecurityTipsUseCase: UseCase<Void, GetSecurityTipsUseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSecurityTipsUseOutput, StringErrorOutput> {
        let appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        guard let securityTips = try checkRepositoryResponse(appRepository.getSecurityTips()) ?? nil else {
            return .error(StringErrorOutput(nil))
        }
        
        securityTips.forEach {
            $0.offer = containtOffer(forTip: $0)
        }
        
        return .ok(GetSecurityTipsUseOutput(securityTips: securityTips))
    }
    
    private func containtOffer(forTip tip: PullOfferTipEntity) -> OfferEntity? {
        let pullOfferInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        guard let offerId = tip.offerId, let offerDTO = pullOfferInterpreter.getOffer(offerId: offerId) else {
            return nil
        }
        return OfferEntity(offerDTO)
    }
}

struct GetSecurityTipsUseOutput {
    let securityTips: [PullOfferTipEntity]?
}
