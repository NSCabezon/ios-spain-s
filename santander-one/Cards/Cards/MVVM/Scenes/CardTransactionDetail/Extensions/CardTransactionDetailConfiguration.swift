//
//  CardTransactionDetailConfiguration.swift
//  Cards
//
//  Created by Jose Carlos Estela Anguita on 20/11/2019.
//

import CoreFoundationLib
import CoreDomain

public final class CardTransactionDetailConfiguration {
    
    var selectedCard: CardEntity
    let selectedTransaction: CardTransactionEntity
    let allTransactions: [CardTransactionEntity]
    let showAmountBackground: Bool
    
    var resultTransactions: [CardTransactionWithCardEntity]?
    
    public init(selectedCard: CardEntity, selectedTransaction: CardTransactionEntity, allTransactions: [CardTransactionEntity], showAmountBackground: Bool = true) {
        self.selectedTransaction = selectedTransaction
        self.allTransactions = allTransactions
        self.selectedCard = selectedCard
        self.showAmountBackground = showAmountBackground
    }
    
    public init(selectedCard: CardEntity, selectedTransaction: CardTransactionEntity, resultTransactions: [CardTransactionWithCardEntity], showAmountBackground: Bool = true) {
        self.selectedCard = selectedCard
        self.selectedTransaction = selectedTransaction
        self.allTransactions = resultTransactions.map { $0.cardTransactionEntity }
        self.resultTransactions = resultTransactions
        self.showAmountBackground = showAmountBackground
    }
}
