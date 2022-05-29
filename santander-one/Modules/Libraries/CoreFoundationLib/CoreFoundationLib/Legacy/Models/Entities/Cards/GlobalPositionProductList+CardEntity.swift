//
//  GlobalPositionProductList+CardEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 07/11/2019.
//

import Foundation

extension GlobalPositionProductList where Product == CardEntity {
    
    public func totalCreditBalance() -> Decimal {
        let singleContractFilteredCards: [CardEntity] = all().reduce([]) { cards, card in
            var cards = cards
            guard card.isCreditCard, !cards.contains(where: { $0.dto.contract == card.dto.contract }) else { return cards }
            cards.append(card)
            return cards
        }
        let creditCards = GlobalPositionProductList(products: singleContractFilteredCards)
        return creditCards.totalOfVisibles(with: \.dataDTO?.currentBalance)
    }
}
