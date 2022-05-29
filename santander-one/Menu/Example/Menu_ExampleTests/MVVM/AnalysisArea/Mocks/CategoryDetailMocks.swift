//
//  CategoryDetailMocks.swift
//  Menu_ExampleTests
//
//  Created by Miguel Bragado Sánchez on 8/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CoreDomain

struct CategoryDetailMock: GetFinancialHealthCategoryInputRepresentable {
    
    
    var dateFrom: Date? { "2020-01-01".toDate(dateFormat: "YYYY-MM-DD") }
    var dateTo: Date? { "2022-03-31".toDate(dateFormat: "YYYY-MM-DD") }
    var scale: TimeViewOptions { .mounthly }
    var category: AnalysisAreaCategoryType { .banksAndInsurance }
    var subcategory: [FinancialHealthSubcategoryType] { [.bankFees, .cards] }
    var type: AnalysisAreaCategorization { .expenses }
    var rangeFrom: Int?
    var rangeTo: Int?
    var text: String?
    var products: [GetFinancialHealthCategoryProductInputRepresentable]? {
        [CategoryDetailProductMock(productType: "accounts", productId: "60fe5566ce3b31c6cf84d834"),
        CategoryDetailProductMock(productType: "creditCards", productId: "60fe5568ce3b31c6cf84df19"),
        CategoryDetailProductMock(productType: "creditCards", productId: "60fe5568ce3b31c6cf84e12a"),
        CategoryDetailProductMock(productType: "creditCards", productId: "60fe5567ce3b31c6cf84da6a"),
        CategoryDetailProductMock(productType: "creditCards", productId: "60fe5567ce3b31c6cf84de46"),
        CategoryDetailProductMock(productType: "creditCards", productId: "60fe5567ce3b31c6cf84dc7a")]
    }
}

struct CategoryDetailProductMock: GetFinancialHealthCategoryProductInputRepresentable {
    var productType: String?
    var productId: String?
}

struct TransactionInfoMock: GetFinancialHealthTransactionsInputRepresentable {
    var dateFrom: Date { "2020-01-01".toDate(dateFormat: "YYYY-MM-DD") }
    var dateTo: Date { "2022-03-31".toDate(dateFormat: "YYYY-MM-DD") }
    var page: String { "1" }
    var scale: TimeViewOptions { .mounthly }
    var category: AnalysisAreaCategoryType { .banksAndInsurance }
    var subCategory: [FinancialHealthSubcategoryType] { [.bankFees, .cards] }
    var type: AnalysisAreaCategorization { .expenses }
    var rangeFrom: Int?
    var rangeTo: Int?
    var text: String?
    var products: [GetFinancialHealthCategoryProductInputRepresentable] {
        [CategoryDetailProductMock(productType: "account", productId: "60fe5566ce3b31c6cf84d834"),
        CategoryDetailProductMock(productType: "creditCards", productId: "60fe5568ce3b31c6cf84df19"),
        CategoryDetailProductMock(productType: "creditCards", productId: "60fe5568ce3b31c6cf84e12a"),
        CategoryDetailProductMock(productType: "creditCards", productId: "60fe5567ce3b31c6cf84da6a"),
        CategoryDetailProductMock(productType: "creditCards", productId: "60fe5567ce3b31c6cf84de46"),
        CategoryDetailProductMock(productType: "creditCards", productId: "60fe5567ce3b31c6cf84dc7a")]
    }
}
