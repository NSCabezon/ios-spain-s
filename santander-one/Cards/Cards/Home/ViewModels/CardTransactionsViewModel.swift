//
//  CardTransactionViewModel.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/29/19.
//

import Foundation
import CoreFoundationLib

public class CardTransactionsGroupViewModel {
    public let date: Date
    let transactions: [CardTransactionViewModel]
    private let dependenciesResolver: DependenciesResolver
    private let card: CardEntity
    private let minEasyPayAmount: Double?
    
    init(date: Date,
         transactions: [CardTransactionEntityProtocol],
         card: CardEntity,
         minEasyPayAmount: Double?,
         dependenciesResolver: DependenciesResolver,
         easyPaymentEnabled: Bool,
         crossSellingEnabled: Bool,
         cardsCrossSelling: [CardsMovementsCrossSellingProperties]) {
        self.card = card
        self.date = date
        self.minEasyPayAmount = minEasyPayAmount
        self.transactions = transactions.map {
            CardTransactionViewModel(transaction: $0,
                                     card: card,
                                     minEasyPayAmount: minEasyPayAmount,
                                     easyPaymentEnabled: easyPaymentEnabled,
                                     crossSellingEnabled: crossSellingEnabled,
                                     cardsCrossSelling: cardsCrossSelling)
        }
        self.dependenciesResolver = dependenciesResolver
    }
    
    func setDateFormatterFiltered(_ filtered: Bool) -> LocalizedStylableText {
        let decorator = DateDecorator(self.date)
        return decorator.setDateFormatter(filtered)
    }
}
