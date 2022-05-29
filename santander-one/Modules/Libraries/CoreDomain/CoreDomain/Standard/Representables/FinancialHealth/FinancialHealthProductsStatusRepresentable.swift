//
//  FinancialHealthStatusRepresentable.swift
//  CoreDomain
//
//  Created by Miguel Ferrer Fornali on 17/2/22.
//

import Foundation

public protocol FinancialHealthProductsStatusRepresentable {
    var lastUpdatedRequestDate: Date? { get }
    var lastUpdatedDate: Date? { get }
    var oldestTransactionDate: Date? { get }
    var status: String? { get }
    var entitiesData: [FinancialHealthEntityRepresentable]? { get }
}

public protocol FinancialHealthEntityRepresentable {
    var company: String? { get }
    var lastUpdateDate: Date? { get }
    var status: String? { get }
    var type: String? { get }
    var message: String? { get }
}
