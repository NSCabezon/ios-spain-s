//
//  HomeMocks.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 25/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import CoreDomain

struct MockGetSummary: GetFinancialHealthSummaryRepresentable {
    var dateFrom: Date {
        "2020-01-01".toDate(dateFormat: "YYYY-MM-DD")
    }
    var dateTo: Date {
        "2022-10-30".toDate(dateFormat: "YYYY-MM-DD")
    }
    var products: [FinancialHealthProductRepresentable]? = [MockProductRepresentable()]
    
    private struct MockProductRepresentable: FinancialHealthProductRepresentable {
        var productType: String? = "accounts"
        var productId: String? = "617957554a037c50e486cbb3"
    }
}

struct FinancialHealthSummaryItemRepresentableMock: FinancialHealthSummaryItemRepresentable {
    var code: String?
    var transactions: Int?
    var total: Double?
    var percentage: Int?
    var currency: String?
    var type: Int?
}

struct FinancialHealthCompanyRepresentableMock: FinancialHealthCompanyRepresentable {
    var company: String?
    var companyName: String?
    var companyProducts: [FinancialHealthCompanyProductRepresentable]?
    var bankImageUrlPath: String?
    var cardImageUrlPath: String?
}

struct FinancialHealthProductsStatusRepresentableMock: FinancialHealthProductsStatusRepresentable {
    var lastUpdatedRequestDate: Date?
    var lastUpdatedDate: Date?
    var oldestTransactionDate: Date?
    var status: String?
    var entitiesData: [FinancialHealthEntityRepresentable]? = [FinancialHealthEntityRepresentableMock()]
    
    private struct FinancialHealthEntityRepresentableMock: FinancialHealthEntityRepresentable {
        var company: String?
        var lastUpdateDate: Date?
        var status: String? = "OK"
        var type: String?
        var message: String?
    }
}
