import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetCreditCardsDomainCase: UseCase<Void, GetCreditCardsDomainCaseOkOutput, GetCreditCardsDomainCaseErrorOutput> {

    private let bsanManagersProvider: BSANManagersProvider

    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }

    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCreditCardsDomainCaseOkOutput, GetCreditCardsDomainCaseErrorOutput> {
        let allCards = try checkRepositoryResponse(bsanManagersProvider.getBsanCardsManager().getAllCards())

        if let allCards = allCards, !allCards.isEmpty {
            var creditCards = [CardDTO]()
            for cardDTO in allCards {
                if CardFactory.isCreditCard(cardDTO: cardDTO) {
                    creditCards.append(cardDTO)
                }
            }
            return UseCaseResponse.ok(GetCreditCardsDomainCaseOkOutput(cards: creditCards))
        }

        return UseCaseResponse.error(GetCreditCardsDomainCaseErrorOutput("no credit card"))
    }
}

struct GetCreditCardsDomainCaseOkOutput {
    var cards: [CardDTO]

    init(cards: [CardDTO]) {
        self.cards = cards
    }
}

class GetCreditCardsDomainCaseErrorOutput: StringErrorOutput {

}
