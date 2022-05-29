import CoreFoundationLib
import SANLegacyLibrary

final class GetAnalysisFinancialBudgetHelpUseCase: UseCase<GetAnalysisFinancialBudgetHelpUseCaseInput, GetAnalysisFinancialBudgetHelpUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAnalysisFinancialBudgetHelpUseCaseInput) throws -> UseCaseResponse<GetAnalysisFinancialBudgetHelpUseCaseOkOutput, StringErrorOutput> {
        let pullOffersConfigRepository = dependenciesResolver.resolve(for: PullOffersConfigRepositoryProtocol.self)
        guard let financialBudgetOffers = pullOffersConfigRepository.getAnalysisFinancialBudgetHelp() else {
            return .error(StringErrorOutput(nil))
        }
        let offersEntity = self.getFinancialOffers(financialBudgetOffers)
        let offerCustomTip = getValidPullOffer(offersEntity, financialBudget: requestValues.financialBudgetMonths, currentDayNumber: requestValues.currentDayNumber)
        return .ok(GetAnalysisFinancialBudgetHelpUseCaseOkOutput(financialBudgetOffer: offerCustomTip))
    }
    
    func getFinancialOffers(_ financialBudgetOffers: [PullOffersConfigBudgetDTO]) -> [PullOffersBudgetRangesEntity] {
        let pullOffersInterpreter = dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let financialBudgetOffers = financialBudgetOffers.compactMap { (dto) -> (PullOffersBudgetRangesEntity)? in
            guard let offersId = dto.offersID else { return PullOffersBudgetRangesEntity(dto, offer: nil) }
            let offerCandidate = offersId.compactMap { (offerId) -> OfferEntity? in
                if let offer = pullOffersInterpreter.getValidOffer(offerId: offerId) {
                    return OfferEntity(offer)
                } else {
                    return nil
                }
            }.first
            return PullOffersBudgetRangesEntity(dto, offer: offerCandidate)
        }
        return financialBudgetOffers
    }
    
    func getValidPullOffer(_ offers: [PullOffersBudgetRangesEntity], financialBudget: Int, currentDayNumber: Int) -> PullOffersBudgetRangesEntity? {
        let financialCushionOffer = offers.first(where: { (entity) -> Bool in
            if let greaterThan = entity.currentBudget.greaterAndEqualThan, financialBudget >= greaterThan,
               let lessThan = entity.currentBudget.lessThan, financialBudget < lessThan,
               let currentDayGreaterThan = entity.currentDay.greaterAndEqualThan, currentDayNumber >= currentDayGreaterThan,
               let currentDayLessThan = entity.currentDay.lessThan, currentDayNumber < currentDayLessThan {
                return true
            } else if let greaterThan = entity.currentBudget.greaterAndEqualThan, financialBudget >= greaterThan,
                      entity.currentBudget.lessThan == nil,
                      let currentDayGreaterThan = entity.currentDay.greaterAndEqualThan, currentDayNumber >= currentDayGreaterThan,
                      let currentDayLessThan = entity.currentDay.lessThan, currentDayNumber < currentDayLessThan {
                return true
            }
            return false
        })
        return financialCushionOffer
    }
}

struct GetAnalysisFinancialBudgetHelpUseCaseInput {
    let financialBudgetMonths: Int
    let currentDayNumber: Int
}

struct GetAnalysisFinancialBudgetHelpUseCaseOkOutput {
    let financialBudgetOffer: PullOffersBudgetRangesEntity?
}
