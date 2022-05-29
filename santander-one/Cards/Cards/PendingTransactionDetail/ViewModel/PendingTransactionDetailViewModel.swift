//
//  PendingTransactionDetailViewModel.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 9/16/20.
//

import CoreFoundationLib
import Foundation

final class PendingTransactionDetailViewModel {
    let transaction: CardPendingTransactionEntity
    let timeManager: TimeManager
    let cardEntity: CardEntity
    
    init(_ transaction: CardPendingTransactionEntity, cardEntity: CardEntity, timeManager: TimeManager) {
        self.transaction = transaction
        self.timeManager = timeManager
        self.cardEntity = cardEntity
    }
    
    var description: String {
        return transaction.description?.capitalized ?? ""
    }
    
    var cardAlias: String {
        return cardEntity.alias ?? ""
    }
    
    var amount: NSAttributedString? {
        guard let amount = transaction.amount else { return nil }
        let font = UIFont.santander(family: .text, type: .bold, size: 32)
        let moneyDecorator = MoneyDecorator(amount, font: font)
        return moneyDecorator.getFormatedCurrency()
    }
    
    var annotationDate: String {
        return timeManager
            .toString(date: transaction.annotationDate, outputFormat: .dd_MMM_yyyy)?
            .lowercased() ?? ""
    }
    
    var operationTime: String {
        return timeManager
            .toString(input: self.transaction.transactionTime, inputFormat: TimeFormat.HHmmssZ, outputFormat: TimeFormat.HHmm) ?? ""
    }
}

extension PendingTransactionDetailViewModel: Equatable {
    static func == (lhs: PendingTransactionDetailViewModel, rhs: PendingTransactionDetailViewModel) -> Bool {
        return lhs.transaction == rhs.transaction
    }
}

extension PendingTransactionDetailViewModel: Shareable {
    func getShareableInfo() -> String {
        return CardTransactionDetailStringBuilder()
            .add(description: description)
            .add(amount: amount)
            .add(annotationDate: annotationDate)
            .build()
    }
}
