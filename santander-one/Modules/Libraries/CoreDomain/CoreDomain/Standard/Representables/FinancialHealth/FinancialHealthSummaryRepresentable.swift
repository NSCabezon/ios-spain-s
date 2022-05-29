//
//  FinancialHealthSummaryRepresentable.swift
//  CoreDomain
//
//  Created by Luis Escámez Sánchez on 15/2/22.
//

import Foundation

public protocol FinancialHealthSummaryItemRepresentable {
    var code: String? { get }
    var transactions: Int? { get }
    var total: Double? { get }
    var percentage: Int? { get }
    var currency: String? { get }
    var type: Int? { get }
}
