//
//  CardTransactionsFiltersAvailableRepresentable.swift
//  CoreDomain
//
//  Created by Gloria Cano López on 22/4/22.
//

public protocol CardTransactionAvailableFiltersRepresentable {
    var byAmount: Bool { get }
    var byExpenses: Bool { get }
    var byTypeOfMovement: Bool { get }
    var byConcept: Bool { get }
}
