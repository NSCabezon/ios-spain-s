import SANLegacyLibrary
import SANLegacyLibrary
import CoreFoundationLib

struct CardFactory {
    struct Constants {
        fileprivate struct ECash {
            static let miniTypeProduct = "502"
            static let miniSubtypeProduct = "536"
        }
    }
    
    static func getCard(_ cardEntity: CardEntity) -> Card {
        switch cardEntity.cardType {
        case .debit: return DebitCard(cardDTO: cardEntity.dto, cardDataDTO: cardEntity.dataDTO, temporallyOffCard: cardEntity.isTemporallyOff, inactiveCard: cardEntity.isInactive)
        case .credit: return CreditCard.createCreditCard(cardEntity: cardEntity)
        case .prepaid: return PrepaidCard(cardDTO: cardEntity.dto, cardDataDTO: cardEntity.dataDTO, temporallyOffCard: cardEntity.isTemporallyOff, inactiveCard: cardEntity.isInactive, cardBalanceDTO: nil)
        }
    }
    
    static func getCard(cardDTO: CardDTO, cardDataDTO: CardDataDTO?,
                        temporallyOffCard: InactiveCardDTO?,
                        inactiveCard: InactiveCardDTO?,
                        prepaidCardDataDTO: PrepaidCardDataDTO?,
                        cardBalance: CardBalanceDTO?) -> Card {
        if isCreditCard(cardDTO: cardDTO) {
            return CreditCard.createCreditCard(cardDTO: cardDTO, cardDataDTO: cardDataDTO, temporallyOffCard: temporallyOffCard, inactiveCard: inactiveCard, cardBalanceDTO: cardBalance)
        } else if isPrepaidCard(cardDTO: cardDTO) {
            return PrepaidCard.createPrepaidCard(cardDTO: cardDTO, cardDataDTO: cardDataDTO, temporallyOffCard: temporallyOffCard, inactiveCard: inactiveCard, cardBalanceDTO: cardBalance)
        }
        return DebitCard.createDebitCard(cardDTO: cardDTO, cardDataDTO: cardDataDTO, temporallyOffCard: temporallyOffCard, inactiveCard: inactiveCard)
    }
    
    static func getCard(cardDTO: CardDTO, cardsManager: BSANCardsManager) -> Card? {
        
        let cardDataDTO = try? cardsManager.getCardData(cardDTO.PAN ?? "").getResponseData()
        let temporallyOffCard = try? cardsManager.getTemporallyOffCard(pan: cardDTO.PAN ?? "").getResponseData()
        let inactiveCard = try? cardsManager.getInactiveCard(pan: cardDTO.PAN ?? "").getResponseData()
        
        guard let cardDataStrong = cardDataDTO,
            let temporallyOffCardStrong = temporallyOffCard,
            let inactiveCardStrong = inactiveCard else { return nil }

        if isCreditCard(cardDTO: cardDTO),
            let cardBalanceDTO = try? cardsManager.getCardBalance(cardDTO: cardDTO).getResponseData() {
            let cardBalanceDTOStrong = cardBalanceDTO

            return CreditCard.createCreditCard(cardDTO: cardDTO, cardDataDTO: cardDataStrong, temporallyOffCard: temporallyOffCardStrong, inactiveCard: inactiveCardStrong, cardBalanceDTO: cardBalanceDTOStrong)
        } else if isPrepaidCard(cardDTO: cardDTO),
            let cardBalanceDTO = try? cardsManager.getCardBalance(cardDTO: cardDTO).getResponseData() {
            let cardBalanceDTOStrong = cardBalanceDTO

            return PrepaidCard.createPrepaidCard(cardDTO: cardDTO, cardDataDTO: cardDataStrong, temporallyOffCard: temporallyOffCardStrong, inactiveCard: inactiveCardStrong, cardBalanceDTO: cardBalanceDTOStrong)
        }
        
        return DebitCard.createDebitCard(cardDTO: cardDTO, cardDataDTO: cardDataStrong, temporallyOffCard: temporallyOffCardStrong, inactiveCard: inactiveCardStrong)
    }
    
    static func isEcashMini(cardDTO: CardDTO) -> Bool {
        var isEcashMini = false
        
        if cardDTO.productSubtypeDTO != nil &&
            Constants.ECash.miniTypeProduct == cardDTO.productSubtypeDTO!.productType &&
            Constants.ECash.miniSubtypeProduct == cardDTO.productSubtypeDTO!.productSubtype {
            isEcashMini = true
        }
        return isEcashMini
    }
    
    /**
     * Devuelve true si es una tarjeta de crédito
     */
    static func isCreditCard(cardDTO: CardDTO) -> Bool {
        guard let type = cardDTO.cardType?.uppercased() else {
            return cardDTO.cardTypeDescription?.lowercased().starts(with: "c") ?? false
        }
        return type == "C"
    }
    
    /**
     * Devuelve true si es la tarjeta Prepago
     */
    static func isPrepaidCard(cardDTO: CardDTO) -> Bool {
        guard let type = cardDTO.cardType?.uppercased() else {
            return cardDTO.eCashInd || isEcashMini(cardDTO: cardDTO)
        }
        return type == "P"
    }
}

