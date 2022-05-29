//
//  GetFinancialHealthSummaryDTO.swift
//  SANLibraryV3
//
//  Created by Luis Escámez Sánchez on 15/2/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

struct GetFinanciaHealthSummaryDTO: Encodable {
    var fromDate: String
    var toDate: String
    var productDTOList: [FinancialHealthProductDTO]?
    
    init?(_ representable: GetFinancialHealthSummaryRepresentable) {
        let dateFrom = representable.dateFrom ?? Date()
        let dateTo = representable.dateTo ?? Date()
        self.fromDate = dateFrom.toString(.YYYYMMDD)
        self.toDate = dateTo.toString(.YYYYMMDD)
        self.productDTOList = representable.products?.map{ FinancialHealthProductDTO($0) }
    }
    
    enum CodingKeys: String, CodingKey {
        case fromDate = "dateFrom"
        case toDate = "dateTo"
        case productDTOList = "products"
    }
}

extension GetFinanciaHealthSummaryDTO: GetFinancialHealthSummaryRepresentable {
    var dateFrom: Date {
        return fromDate.toDate(dateFormat: TimeFormat.yyyyMMdd.rawValue)
    }
    var dateTo: Date {
        return toDate.toDate(dateFormat: TimeFormat.yyyyMMdd.rawValue)
    }
    var products: [FinancialHealthProductRepresentable]? {
        return productDTOList
    }
}

struct FinancialHealthProductDTO: FinancialHealthProductRepresentable, Encodable {
    var productType: String?
    var productId: String?
    
    init(_ representable: FinancialHealthProductRepresentable) {
        self.productType = representable.productType
        self.productId = representable.productId
    }
    
    enum CodingKeys: String, CodingKey {
        case productType = "productType"
        case productId = "id"
    }
}
