//
//  GetSSantanderExperiencesUseCase.swift
//  GlobalPosition
//
//  Created by César González Palomino on 18/05/2020.
//

import CoreFoundationLib

final class GetSSantanderExperiencesUseCase: UseCase<Void, GetSantanderExperiencesOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSantanderExperiencesOutput, StringErrorOutput> {
        let appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        
        guard let experiences = try checkRepositoryResponse(appRepository.getSantanderExperiences()) ?? nil else {
            return .error(StringErrorOutput(nil))
        }
        
        experiences.forEach {
            $0.offer = containtOffer(forTip: $0)
        }
        
        return .ok(GetSantanderExperiencesOutput(santanderExperiences: experiences))
    }  
}

private extension GetSSantanderExperiencesUseCase {
    private func containtOffer(forTip tip: PullOfferTipEntity) -> OfferEntity? {
           let pullOfferInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
           guard let offerId = tip.offerId, let offerDTO = pullOfferInterpreter.getOffer(offerId: offerId) else {
               return nil
           }
           return OfferEntity(offerDTO)
       }
}

struct GetSantanderExperiencesOutput {
    let santanderExperiences: [PullOfferTipEntity]
}
