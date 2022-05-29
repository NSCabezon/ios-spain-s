//
//  SplitableItem.swift
//  Pods
//
//  Created by Hernán Villamil on 22/4/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

public final class SplitableCardTransaction {
    private let card: CardRepresentable
    private let transaction: CardTransactionRepresentable
    
    init(card: CardRepresentable, transaction: CardTransactionRepresentable) {
        self.card = card
        self.transaction = transaction
    }
}

extension SplitableCardTransaction: SplitableExpenseProtocol {
    public var amount: AmountEntity {
        guard let amount = transaction.amountRepresentable else {
            return AmountEntity(value: 0)
        }
        return AmountEntity(amount)
    }
    
    public var productAlias: String {
        return transaction.description?.capitalized ?? ""
    }
    
    public var concept: String {
        return card.alias ?? ""
    }
}
