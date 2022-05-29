import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetECashCardsWithoutDataDomainCase: UseCase<Void, GetECashCardsWithoutDataDomainCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetECashCardsWithoutDataDomainCaseOkOutput, StringErrorOutput> {
        let allCards = try checkRepositoryResponse(managersProvider.getBsanCardsManager().getAllCards())

        if let allCards = allCards, !allCards.isEmpty {
            var eCashCards = [CardDTO]()
            for cardDTO in allCards {
                if CardEntity(cardDTO).isPrepaidCard, let pan = cardDTO.PAN {
                    let cardDataDTO = try managersProvider.getBsanCardsManager().getCardData(pan).getResponseData()
                    if cardDataDTO == nil {
                        eCashCards.append(cardDTO)
                    }
                }
            }
            return UseCaseResponse.ok(GetECashCardsWithoutDataDomainCaseOkOutput(cards: eCashCards))
        }

        return UseCaseResponse.error(StringErrorOutput("no ecash"))
    }

}

extension GetECashCardsWithoutDataDomainCase: RepositoriesResolvable {}

struct GetECashCardsWithoutDataDomainCaseOkOutput {
    let cards: [CardDTO]
}
