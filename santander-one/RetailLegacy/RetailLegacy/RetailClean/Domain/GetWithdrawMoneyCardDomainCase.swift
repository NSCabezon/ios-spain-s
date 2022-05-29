import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetWithdrawMoneyCardDomainCase: UseCase<Void, GetWithdrawMoneyCardDomainCaseOkOutput, GetWithdrawMoneyCardDomainCaseErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetWithdrawMoneyCardDomainCaseOkOutput, GetWithdrawMoneyCardDomainCaseErrorOutput> {
        let allCards = try checkRepositoryResponse(bsanManagersProvider.getBsanCardsManager().getAllCards())
        
        let filtered = allCards?.filter { cardDTO in
            let debitCard = CardFactory.getCard(cardDTO: cardDTO, cardsManager: bsanManagersProvider.getBsanCardsManager())
            guard let card = debitCard, card.allowWithdrawMoneyWithCode else {
                return false
            }
            return true
        }.compactMap { CardFactory.getCard(cardDTO: $0, cardsManager: bsanManagersProvider.getBsanCardsManager()) }
        
        let withdrawCards = filtered ?? []
        return UseCaseResponse.ok(GetWithdrawMoneyCardDomainCaseOkOutput(cards: withdrawCards))
    }
}

struct GetWithdrawMoneyCardDomainCaseOkOutput {
    let cards: [Card]
}

class GetWithdrawMoneyCardDomainCaseErrorOutput: StringErrorOutput {
    
}
