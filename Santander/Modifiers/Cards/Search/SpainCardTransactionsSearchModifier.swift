//
//  SpainCardTransactionsSearchModifier.swift
//  Santander
//
//  Created by Fernando Sánchez García on 16/9/21.
//

import Foundation
import Cards
import CoreFoundationLib
import UI

final class SpainCardTransactionsSearchModifier {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension SpainCardTransactionsSearchModifier: CardTransactionsSearchModifierProtocol {
    var isSearchLimitedBySCA: Bool {
        return true
    }
    
    var isTransactionNameFilterEnabled: Bool {
        return true
    }

    var isIncomeExpensesFilterEnabled: Bool {
        return false
    }
    
    var isAmountsRangeFilterEnabled: Bool {
        return false
    }
    
    var isOperationTypeFilterEnabled: Bool {
        return true
    }
}
