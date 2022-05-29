//
//  NextSettlementMovementWithPANViewModel.swift
//  Cards
//
//  Created by Laura González on 22/10/2020.
//

import Foundation
import CoreFoundationLib

final class NextSettlementMovementWithPANViewModel {
    let cardEntity: CardEntity
    let movementsEntity: [CardSettlementMovementEntity]?
    
    init(_ cardEntity: CardEntity, movementsEntity: [CardSettlementMovementEntity]?) {
        self.cardEntity = cardEntity
        self.movementsEntity = movementsEntity
    }
    
    public var isTitular: Bool {
        return cardEntity.isOwnerSuperSpeed
    }
    
    var movements: [NextSettlementMovementViewModel] {
        guard let movementsEntity = movementsEntity, movementsEntity.count > 0 else { return [] }
        let movements = movementsEntity.map { NextSettlementMovementViewModel($0) }
        return movements
    }
    
    var totalExpenses: Double {
        var total: Double = 0
        self.movements.forEach({ total += $0.amount ?? 0 })
        return total
    }
    
    var totalExpensesText: String {
        let defaultCurrency = MoneyDecorator.defaultCurrency
        let amountFormatted = Decimal(self.totalExpenses).decorateAmount(defaultCurrency)
        return amountFormatted
    }
}
