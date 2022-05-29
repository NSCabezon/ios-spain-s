//
//  GetFinancialHealthSummaryRepresentable.swift
//  CoreDomain
//
//  Created by Luis Escámez Sánchez on 15/2/22.
//

import Foundation

public protocol GetFinancialHealthSummaryRepresentable {
    var dateFrom: Date { get }
    var dateTo: Date { get }
    var products: [FinancialHealthProductRepresentable]? { get }
}

public protocol FinancialHealthProductRepresentable {
    var productType: String? { get }
    var productId: String? { get }
}
