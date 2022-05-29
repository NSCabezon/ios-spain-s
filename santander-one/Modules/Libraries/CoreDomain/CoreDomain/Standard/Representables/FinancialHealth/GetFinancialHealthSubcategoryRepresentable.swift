//
//  GetFinancialHealthCategoriesRepresentable.swift
//  CoreDomain
//
//  Created by Miguel Bragado Sánchez on 1/4/22.
//

import Foundation

public protocol GetFinancialHealthSubcategoryRepresentable {
    var subcategory: FinancialHealthSubcategoryType? { get }
    var totalAmount: AmountRepresentable? { get }
    var periods: [GetFinancialHealthSubcategoryPeriodRepresentable]? { get }
}

public protocol GetFinancialHealthSubcategoryPeriodRepresentable {
    var periodName: String? { get }
    var periodAmount: AmountRepresentable? { get }
    var periodDateFrom: Date? { get }
    var periodDateTo: Date? { get }
    var periodAmountExpected: AmountRepresentable? { get }
}
