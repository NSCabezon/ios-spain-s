//
//  CardTransaction.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 28/1/22.
//

import Foundation
import CoreFoundationLib

enum CardMovementType {
    case list(cardTransaction: CardTransactionEntity)
    case pending(cardPendingTransaction: CardPendingTransactionEntity)
}

struct CardMovement {
    let movement: CardTransactionEntityProtocol
    let transaction: CardMovementType
    
    init(transaction: CardTransactionEntity) {
        movement = transaction
        self.transaction = .list(cardTransaction: transaction)
    }
    
    init(transaction: CardPendingTransactionEntity) {
        movement = transaction
        self.transaction = .pending(cardPendingTransaction: transaction)
    }
}
