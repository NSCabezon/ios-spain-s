//
//  GetFinancialHealthTransactionsRepresentable.swift
//  SANLibraryV3
//
//  Created by Miguel Bragado Sánchez on 5/4/22.
//

import Foundation
import CoreDomain

public protocol GetFinancialHealthTransactionRepresentable {
    var transactionType: AnalysisAreaCategorization? { get }
    var transactionProductNumber: String? { get }
    var transactionDate: Date? { get }
    var transactionTotal: AmountRepresentable? { get }
    var transactionDescription: String? { get }
    var transactionSubCategory: FinancialHealthSubcategoryType? { get }
    var transactionCategory: AnalysisAreaCategoryType? { get }
    var transactionProductType: CategoryProductType? { get }
    var transactionParentId: String? { get }
}
