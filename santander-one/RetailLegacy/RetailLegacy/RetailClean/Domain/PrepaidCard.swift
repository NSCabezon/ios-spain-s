import SANLegacyLibrary
import CoreFoundationLib

class PrepaidCard: Card {
    static func createPrepaidCard(cardDTO: CardDTO,
                                  cardDataDTO: CardDataDTO?,
                                  temporallyOffCard: InactiveCardDTO?,
                                  inactiveCard: InactiveCardDTO?,
                                  cardBalanceDTO: CardBalanceDTO?) -> PrepaidCard {
        return PrepaidCard(cardDTO: cardDTO, cardDataDTO: cardDataDTO, temporallyOffCard: temporallyOffCard != nil, inactiveCard: inactiveCard != nil, cardBalanceDTO: cardBalanceDTO)
    }
    
    var cardBalanceDTO: CardBalanceDTO? {
        return cardEntity.cardBalanceDTO
    }
    
    init(cardDTO: CardDTO,
         cardDataDTO: CardDataDTO?,
         temporallyOffCard: Bool,
         inactiveCard: Bool,
         cardBalanceDTO: CardBalanceDTO?) {
        super.init(CardEntity(cardRepresentable: cardDTO, cardDataDTO: cardDataDTO, cardBalanceDTO: cardBalanceDTO, temporallyOff: temporallyOffCard, inactiveCard: inactiveCard))
    }
    
    override func getAmountDTOValue() -> Amount? {
        return getPrepaidBalance()
    }
    
    func getPrepaidBalance() -> Amount {
        if let dto = cardDataDTO, let availableAmount = dto.availableAmount {
            return Amount.createFromDTO(availableAmount)
        }
        
        if let dto = cardBalanceDTO {
            return Amount.createFromDTO(dto.currentBalance)
        }
        
        return Amount.createFromDTO(nil)
    }
    
    override func getAmountUI() -> String {
        return getAmount()?.getFormattedAmountUIWith1M() ?? ""
    }
    
    /**
     * Permite la recarga de tarjetas prepago
     */
    override var allowPrepaidCharge: Bool {
        return isActive
    }
}
