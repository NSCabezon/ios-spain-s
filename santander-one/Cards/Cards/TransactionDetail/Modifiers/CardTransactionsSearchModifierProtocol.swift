//
//  CardTransactionsSearchModifierProtocol.swift
//  Cards
//
//  Created by Fernando Sánchez García on 8/9/21.
//

import Foundation

public protocol CardTransactionsSearchModifierProtocol {
    var isSearchLimitedBySCA: Bool { get }
    var isTransactionNameFilterEnabled: Bool { get }
    var isIncomeExpensesFilterEnabled: Bool { get }
    var isAmountsRangeFilterEnabled: Bool { get }
    var isOperationTypeFilterEnabled: Bool { get }
}
