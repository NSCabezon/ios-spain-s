//
//  NextSettlementMovementViewModel.swift
//  Models
//
//  Created by Laura González on 13/10/2020.
//

import Foundation
import CoreFoundationLib

final class NextSettlementMovementViewModel {
    let entity: CardSettlementMovementEntity
    
    init(_ entity: CardSettlementMovementEntity) {
        self.entity = entity
    }
    
    var date: String {
        return dateToString(date: entity.movementDate, outputFormat: .d_MMM_yyyy)?.uppercased() ?? ""
    }
    
    var amount: Double? {
        guard let amount = entity.movementAmount else { return nil }
        return amount
    }
    
    var amountText: String {
        guard let amount = entity.movementAmount else { return "" }
        let defaultCurrency = MoneyDecorator.defaultCurrency
        let amountFormatted = Decimal(amount).decorateAmount(defaultCurrency)
        return amountFormatted
    }
    
    var concept: String? {
        guard let movementConcept = entity.movementConcept else { return nil }
        return movementConcept
    }
    
    var completeDate: Date? {
        return entity.movementDate
    }
}
