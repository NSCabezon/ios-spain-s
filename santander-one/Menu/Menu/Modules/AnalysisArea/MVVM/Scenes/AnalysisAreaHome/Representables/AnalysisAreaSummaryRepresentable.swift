//
//  AnalysisAreaSummaryRepresentable.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 8/3/22.
//

import CoreDomain

struct AnalysisAreaSummaryItemRepresentable {
    var itemCode: String?
    var itemMovements: Int?
    var itemAmount: Double?
    var itemPercentage: Int?
    var itemCurrency: String?
    var itemTtype: Int?
}

extension AnalysisAreaSummaryItemRepresentable: FinancialHealthSummaryItemRepresentable {
    var code: String? {
        itemCode
    }
    
    var transactions: Int? {
        itemMovements
    }
    
    var total: Double? {
        itemAmount
    }
    
    var percentage: Int? {
        itemPercentage
    }
    
    var currency: String? {
        itemCurrency
    }
    
    var type: Int? {
        itemTtype
    }
}
