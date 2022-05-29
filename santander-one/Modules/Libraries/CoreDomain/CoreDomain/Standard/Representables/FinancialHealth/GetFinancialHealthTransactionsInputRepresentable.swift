//
//  GetFinancialHealthTransactionsInputRepresentable.swift
//  SANLibraryV3
//
//  Created by Miguel Bragado Sánchez on 5/4/22.
//

import Foundation
import CoreDomain

public protocol GetFinancialHealthTransactionsInputRepresentable {
    var dateFrom: Date { get }
    var dateTo: Date { get }
    var page: String { get }
    var scale: TimeViewOptions { get }
    var category: AnalysisAreaCategoryType { get }
    var subCategory: [FinancialHealthSubcategoryType] { get }
    var type: AnalysisAreaCategorization { get }
    var rangeFrom: Int? { get }
    var rangeTo: Int? { get }
    var text: String? { get }
    var products: [GetFinancialHealthCategoryProductInputRepresentable] { get }
}
