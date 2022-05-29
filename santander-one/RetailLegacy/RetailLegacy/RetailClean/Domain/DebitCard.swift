import SANLegacyLibrary
import CoreFoundationLib

class DebitCard: Card {
    static func createDebitCard(cardDTO: CardDTO,
                                cardDataDTO: CardDataDTO?,
                                temporallyOffCard: InactiveCardDTO?,
                                inactiveCard: InactiveCardDTO?) -> DebitCard {
        return DebitCard(cardDTO: cardDTO, cardDataDTO: cardDataDTO, temporallyOffCard: temporallyOffCard != nil, inactiveCard: inactiveCard != nil)
    }
    
    init(cardDTO: CardDTO,
         cardDataDTO: CardDataDTO?,
         temporallyOffCard: Bool,
         inactiveCard: Bool) {
        
        super.init(CardEntity(cardRepresentable: cardDTO, cardDataDTO: cardDataDTO, cardBalanceDTO: nil, temporallyOff: temporallyOffCard, inactiveCard: inactiveCard))
    }
    
    override func getAmountDTOValue() -> Amount? {
        return nil
    }
    
    override func getAmountUI() -> String {
        return ""
    }
    
    /// Allows card limit management
    override var allowsCardLimitManagement: Bool {
        return true
    }
}
