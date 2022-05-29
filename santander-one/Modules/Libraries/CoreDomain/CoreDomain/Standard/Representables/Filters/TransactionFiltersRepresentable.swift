//
//  TransactionFiltersRepresentable.swift
//  Account
//
//  Created by Juan Carlos López Robles on 1/18/22.
//

import Foundation

public protocol TransactionFiltersRepresentable {
    var fromAmount: Decimal? { get }
    var toAmount: Decimal? { get }
    var dateInterval: DateInterval? { get }
}
