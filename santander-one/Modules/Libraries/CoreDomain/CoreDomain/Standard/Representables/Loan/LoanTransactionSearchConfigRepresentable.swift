//
//  LoanDetailRepresentable.swift
//  Loans
//
//  Created by Juan Jose Acosta on 14/3/22.
//

public protocol LoanTransactionSearchConfigRepresentable {
    var isFiltersEnabled: Bool { get }
    var isEnabledConceptFilter: Bool { get }
    var isEnabledOperationTypeFilter: Bool { get }
    var isEnabledAmountRangeFilter: Bool { get }
    var isEnabledDateFilter: Bool { get }
    var isDetailsCarouselEnabled: Bool { get }
}
