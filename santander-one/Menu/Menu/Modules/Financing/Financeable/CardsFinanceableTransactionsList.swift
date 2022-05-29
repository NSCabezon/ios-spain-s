//
//  CardsFinanceableTransactionsList.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 06/07/2020.
//

import Foundation
import CoreFoundationLib

final class CardsFinanceableTransactionsList {
    let card: CardEntity
    var transactions: [CardTransactionEntity] = []
    
    init(card: CardEntity, transactions: [CardTransactionEntity]) {
        self.card = card
        self.transactions = transactions
    }
}

extension CardsFinanceableTransactionsList: Equatable {
    static func == (lhs: CardsFinanceableTransactionsList, rhs: CardsFinanceableTransactionsList) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension CardsFinanceableTransactionsList: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.card.hashValue)
    }
}
