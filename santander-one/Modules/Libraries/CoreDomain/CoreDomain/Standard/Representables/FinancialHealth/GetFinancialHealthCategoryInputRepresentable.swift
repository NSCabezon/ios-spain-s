//
//  GetFinancialHealthCategoryInputRepresentable.swift
//  CoreDomain
//
//  Created by Miguel Bragado Sánchez on 1/4/22.
//

import Foundation

public protocol GetFinancialHealthCategoryInputRepresentable {
    var dateFrom: Date? { get }
    var dateTo: Date? { get }
    var scale: TimeViewOptions { get }
    var category: AnalysisAreaCategoryType { get }
    var subcategory: [FinancialHealthSubcategoryType] { get }
    var type: AnalysisAreaCategorization { get }
    var rangeFrom: Int? { get }
    var rangeTo: Int? { get }
    var text: String? { get }
    var products: [GetFinancialHealthCategoryProductInputRepresentable]? { get }
}

public protocol GetFinancialHealthCategoryProductInputRepresentable {
    var productType: String? { get }
    var productId: String? { get }
}

public enum CategoryProductType: String {
    case accounts
    case creditCards
}
