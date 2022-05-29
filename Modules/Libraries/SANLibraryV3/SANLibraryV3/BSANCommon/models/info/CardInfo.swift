public class CardInfo: Codable {
    public var cardsWithDetail: [String: CardDetailDTO] = [:]
    public var prepaidCards: [String: PrepaidCardDataDTO] = [:]
    public var cardsData: [String: CardDataDTO] = [:]
    public var inactiveCards: [String: InactiveCardDTO] = [:]
    public var temporallyOffCards: [String: InactiveCardDTO] = [:]
    public var easyPayContractTransactionsList: [String: EasyPayContractTransactionListDTO] = [:]
    public var cardTransactionsDictionary: [String: CardTransactionsListDTO] = [:]
    public var cardTransactionDetails: [String: CardTransactionDetailDTO] = [:]
    public var mobileOperatorDTO: MobileOperatorDTO?
    public var validateMobileRechargeDTO: ValidateMobileRechargeDTO?
    public var payLaterDTO: PayLaterDTO?
    public var feesData: [String: FeeDataDTO] = [:]
    public var easyPayDTOs: [String: EasyPayDTO] = [:]
    public var easyPayContractTransactionDTO: EasyPayContractTransactionDTO?
    public var cardBalances: [String: CardBalanceDTO] = [:]

    public func getCardDetail(_ PAN: String) -> CardDetailDTO? {
        return cardsWithDetail[PAN.replace(" ", "")]
    }

    public func addToCardsDetail(_ PAN: String, _ cardDetailDTO: CardDetailDTO) {
        cardsWithDetail[PAN.replace(" ", "")] = cardDetailDTO
    }
    
    public func getPrepaidCardData(_ PAN: String) -> PrepaidCardDataDTO? {
        return prepaidCards[PAN.replace(" ", "")]
    }

    public func addToCardsData(_ cardDataDTO: CardDataDTO) {
        if let PAN = cardDataDTO.PAN {
            cardsData[PAN.replace(" ", "")] = cardDataDTO
        }
    }

    public func getCardData(_ PAN: String) -> CardDataDTO? {
        return cardsData[PAN.replace(" ", "")]
    }
    
    public func getCardBalance(_ PAN: String) -> CardBalanceDTO? {
        return cardBalances[PAN.replace(" ", "")]
    }

    public func addToInactiveCards(_ inactiveCardDTO: InactiveCardDTO) {
        if let PAN = inactiveCardDTO.PAN {
            inactiveCards[PAN.replace(" ", "")] = inactiveCardDTO
        }
    }

    public func getInactiveCard(_ PAN: String) -> InactiveCardDTO? {
        return inactiveCards[PAN.replace(" ", "")]
    }

    public func addToTemporallyOffCards(_ inactiveCardDTO: InactiveCardDTO) {
        if let PAN = inactiveCardDTO.PAN {
            temporallyOffCards[PAN.replace(" ", "")] = inactiveCardDTO
        }
    }

    public func getTemporallyOffCard(_ PAN: String) -> InactiveCardDTO? {
        return temporallyOffCards[PAN.replace(" ", "")]
    }

    public func addToPrepaidCards(_ PAN: String, _ prepaidCardDTO: PrepaidCardDataDTO) {
        prepaidCards[PAN.replace(" ", "")] = prepaidCardDTO
    }
    
    public func addToCardBalances(_ PAN: String, _ cardBalance: CardBalanceDTO) {
        cardBalances[PAN.replace(" ", "")] = cardBalance
    }

    public func addCardTransactions(cardTransactionsListDTO: CardTransactionsListDTO, contract: String) {
        var newStoredTransactions = [CardTransactionDTO]()
        if let storedTransactions = cardTransactionsDictionary[contract]{
            newStoredTransactions = storedTransactions.transactionDTOs
        }
        newStoredTransactions += cardTransactionsListDTO.transactionDTOs
        cardTransactionsDictionary[contract] = CardTransactionsListDTO(transactionDTOs: newStoredTransactions, pagination: cardTransactionsListDTO.pagination)
    }
}
