import SANLegacyLibrary
import Foundation

class CardList: GenericProductList<Card> {
    static func create(_ from: [Card]?) -> CardList {
        return self.init(from ?? [])
    }

    static func createFrom(dtos: [CardDTO]?,
                           cardsData: [String: CardDataDTO]?,
                           prepaidCardsData: [String: PrepaidCardDataDTO]?,
                           cardBalances: [String: CardBalanceDTO]?,
                           temporallyOffCards: [String: InactiveCardDTO]?,
                           inactiveCards: [String: InactiveCardDTO]?) -> CardList {

        let cards = dtos?.compactMap({ dto -> Card in
            let pan = dto.formattedPAN ?? ""
            let card = CardFactory.getCard(cardDTO: dto, cardDataDTO: cardsData?[pan], temporallyOffCard: temporallyOffCards?[pan],
                    inactiveCard: inactiveCards?[pan], prepaidCardDataDTO: prepaidCardsData?[pan], cardBalance: cardBalances?[pan])
            return card
        }) ?? []

        return CardList(cards)
    }
    
    override func getTotalFiltered(_ filter: OwnershipProfile?, _ counterValueEnabled: Bool, _ currencyType: CurrencyType) throws -> Decimal {
        return try getTotalFiltered(filter, counterValueEnabled, currencyType, visibles: true)
    }
    
    func getTotalFiltered(_ filter: OwnershipProfile?, _ counterValueEnabled: Bool, _ currencyType: CurrencyType, visibles: Bool) throws -> Decimal {
        if let result = try? getTotalCreditBalance(filter, currencyType: currencyType, visibles: visibles) {
            return result + getTotalPrepaidBalance(filter: filter, visibles: visibles)
        }
        return 0.0
    }
    
    func getTotalPrepaidBalance(filter: OwnershipProfile? = nil, visibles: Bool = false) -> Decimal {
        let cards = getECashCards(filter).filter({$0.isVisible() == visibles})
        return cards.reduce(Decimal(0)) { reduction, card in
            return reduction + ((card as? PrepaidCard)?.getPrepaidBalance().value ?? 0.0)
        }
    }
    
    func getTotalCounterCreditBalance(_ filter: OwnershipProfile? = nil, currencyType: CurrencyType, visibles: Bool = false) -> Decimal {
        let creditCards = getCreditCards(filter, visibles: visibles)
        var alreadyCount = [ContractDTO]()
        var result = Decimal(0)
        for card in creditCards {
            if let card = card as? CreditCard {
                guard let contract = card.getContractDTO(), let value = card.getCreditBalance().value else {
                    continue
                }
                if let creditCurrency = card.getCreditBalance().currency, currencyType == creditCurrency.currencyType {
                    if creditCurrency.currencyType == currencyType && !alreadyCount.contains(contract) {
                        alreadyCount += [contract]
                        result += value
                    }
                }
            }
        }
        return result
    }
    
    func getTotalCreditBalance(_ filter: OwnershipProfile? = nil, currencyType: CurrencyType, visibles: Bool = false) throws -> Decimal {
        let creditCards = getCreditCards(filter, visibles: visibles)
        var alreadyCount = [ContractDTO]()
        var result = Decimal(0)
        for card in creditCards {
            if let card = card as? CreditCard {
                guard let contract = card.getContractDTO(), let value = card.getCreditBalance().value else {
                    continue
                }
                if let creditCurrency = card.getCreditBalance().currency, currencyType == creditCurrency.currencyType {
                    if creditCurrency.currencyType == currencyType && !alreadyCount.contains(contract) {
                        alreadyCount += [contract]
                        result += value
                    }
                } else {
                    throw MultipleCurrencyException()
                }
            }
        }
        return result
    }

    private func getECashCards(_ filter: OwnershipProfile? = nil) -> [Card] {
        return apply(in: list.filter {
            $0.isPrepaidCard
        }, filter: filter)
    }

    private func getCreditCards(_ filter: OwnershipProfile? = nil, visibles: Bool) -> [Card] {
        let cards: [Card]
        if visibles {
            cards = getVisibles()
        } else {
            cards = list
        }
        return apply(in: cards.filter {
            $0.isCreditCard
        }, filter: filter)
    }
    
    private func apply(in list: [Card], filter: OwnershipProfile?) -> [Card] {
        guard let filter = filter else {
            return list
        }
        return list.filter { filter.matchesFor($0) }
    }
    
    func getMaxAmountCredit(_ filter: OwnershipProfile?) -> Double {
        let products: [Card] = getVisibles(filter)
        return products.filter({($0 is CreditCard)}).sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
    }
    
    func getMinAmountCredit(_ filter: OwnershipProfile?) -> Double {
        let products: [Card] = getVisibles(filter)
        return products.filter({($0 is CreditCard)}).sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
    }
    
    func getMaxAmountDebit(_ filter: OwnershipProfile?) -> Double {
        let products: [Card] = getVisibles(filter)
        return products.filter({($0 is DebitCard)}).sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
    }
    
    func getMinAmountDebit(_ filter: OwnershipProfile?) -> Double {
        let products: [Card] = getVisibles(filter)
        return products.filter({($0 is DebitCard)}).sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
    }
    
    func getMaxAmountPrepaid(_ filter: OwnershipProfile?) -> Double {
        let products: [Card] = getVisibles(filter)
        return products.filter({($0 is PrepaidCard)}).sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
    }
    
    func getMinAmountPrepaid(_ filter: OwnershipProfile?) -> Double {
        let products: [Card] = getVisibles(filter)
        return products.filter({($0 is PrepaidCard)}).sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
    }
}
