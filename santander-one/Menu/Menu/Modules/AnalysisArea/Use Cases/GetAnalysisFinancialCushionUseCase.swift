//
//  GetAnalysisFinancialCushionUseCase.swift
//  Menu
//
//  Created by Tania Castellano Brasero on 31/05/2021.
//

import CoreFoundationLib
import SANLegacyLibrary

final class GetAnalysisFinancialCushionUseCase: UseCase<GetAnalysisFinancialCushionUseCaseInput, GetAnalysisFinancialCushionUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAnalysisFinancialCushionUseCaseInput) throws -> UseCaseResponse<GetAnalysisFinancialCushionUseCaseOkOutput, StringErrorOutput> {
        let pullOffersConfigRepository = dependenciesResolver.resolve(for: PullOffersConfigRepositoryProtocol.self)
        guard let financialCushionOffers = pullOffersConfigRepository.getAnalysisFinancialCushionHelp() else {
            return .error(StringErrorOutput(nil))
        }
        let offersEntity = self.getFinancialOffers(financialCushionOffers)
        let offerCustomTip = getValidPullOffer(offersEntity, financialCushion: requestValues.cushion)
        return .ok(GetAnalysisFinancialCushionUseCaseOkOutput(financialCushionOffer: offerCustomTip))
    }
    
    func getFinancialOffers(_ financialCushionOffers: [PullOffersConfigRangesDTO]) -> [PullOffersRangesEntity] {
        let pullOffersInterpreter = dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let financialCushionOffers = financialCushionOffers.compactMap { (dto) -> (PullOffersRangesEntity)? in
            guard let offersId = dto.offersId else { return PullOffersRangesEntity(dto, offer: nil) }
            let offerCandidate = offersId.compactMap { (offerId) -> OfferEntity? in
                if let offer = pullOffersInterpreter.getValidOffer(offerId: offerId) {
                    return OfferEntity(offer)
                } else {
                    return nil
                }
            }.first
            return PullOffersRangesEntity(dto, offer: offerCandidate)
        }
        return financialCushionOffers
    }
    
    func getValidPullOffer(_ offers: [PullOffersRangesEntity], financialCushion: Int) -> PullOffersRangesEntity? {
        let financialCushionOffer = offers.first(where: { (entity) -> Bool in
            if let greaterThan = entity.greaterAndEqualThan,
               financialCushion >= greaterThan,
               let lessThan = entity.lessThan,
               financialCushion < lessThan {
                return true
            } else if let greaterThan = entity.greaterAndEqualThan,
                      financialCushion >= greaterThan,
                      entity.lessThan == nil {
                return true
            }
            return false
        })
        return financialCushionOffer
    }
}

struct GetAnalysisFinancialCushionUseCaseInput {
    let cushion: Int
}

struct GetAnalysisFinancialCushionUseCaseOkOutput {
    let financialCushionOffer: PullOffersRangesEntity?
}
