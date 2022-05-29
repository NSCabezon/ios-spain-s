//
//  FinancialHealthCompaniesProductsStatusAndSummaryRepresentable.swift
//  CoreDomain
//
//  Created by Miguel Ferrer Fornali on 29/3/22.
//

import Foundation

public protocol FinancialHealthCompaniesProductsStatusAndSummaryRepresentable {
    var companies: [FinancialHealthCompanyRepresentable]? { get }
    var productsStatus: FinancialHealthProductsStatusRepresentable? { get }
    var summary: [FinancialHealthSummaryItemRepresentable]? { get }
}
