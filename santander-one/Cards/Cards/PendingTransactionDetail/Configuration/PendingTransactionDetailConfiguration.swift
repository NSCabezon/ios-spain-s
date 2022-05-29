//
//  PendingTransactionDetailConfiguration.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 9/16/20.
//

import Foundation
import CoreFoundationLib

final class PendingTransactionDetailConfiguration {
    let cardEntity: CardEntity
    let selectedTransaction: CardPendingTransactionEntity
    let transactions: [CardPendingTransactionEntity]
    
    init(selectedCard: CardEntity, selectedTransaction: CardPendingTransactionEntity, transactions: [CardPendingTransactionEntity]) {
        self.cardEntity = selectedCard
        self.selectedTransaction = selectedTransaction
        self.transactions = transactions
    }
}
