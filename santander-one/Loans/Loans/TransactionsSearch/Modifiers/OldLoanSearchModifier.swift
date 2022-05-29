//
//  LoanTransactionModifier.swift
//  Loans
//
//  Created by Rodrigo Jurado on 5/10/21.
//

import Foundation

public protocol OldLoanSearchModifier {
    var isFiltersEnabled: Bool { get }
    var isEnabledConceptFilter: Bool { get }
    var isEnabledOperationTypeFilter: Bool { get }
    var isEnabledAmountRangeFilter: Bool { get }
    var isEnabledDateFilter: Bool { get }
    var isDetailsCarouselEnabled: Bool { get }
}
