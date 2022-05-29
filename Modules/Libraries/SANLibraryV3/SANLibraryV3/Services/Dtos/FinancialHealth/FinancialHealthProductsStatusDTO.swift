//
//  FinancialHealthProductsStatusDTO.swift
//  SANLibraryV3
//
//  Created by Miguel Ferrer Fornali on 21/2/22.
//

import Foundation
import CoreDomain

struct FinancialHealthProductsStatusDTO: Decodable {
    var lastUpdatedRequestStringDate: String?
    var lastUpdatedStringDate: String?
    var oldestTransactionStringDate: String?
    var status: String?
    var entities: [FinancialHealthEntityDTO]?
    
    enum CodingKeys: String, CodingKey {
        case lastUpdatedRequestStringDate = "lastUpdatedRequest"
        case lastUpdatedStringDate = "lastUpdated"
        case oldestTransactionStringDate = "oldestTransactionDate"
        case status = "status"
        case entities = "entities"
    }
}

extension FinancialHealthProductsStatusDTO: FinancialHealthProductsStatusRepresentable {
    var lastUpdatedRequestDate: Date? {
        guard let lastUpdatedRequestStringDate = lastUpdatedRequestStringDate else { return nil }
        return DateFormats.toDate(string: lastUpdatedRequestStringDate, output: .YYYYMMDD_HHmmssSSSSSS)
    }
    
    var lastUpdatedDate: Date? {
        guard let lastUpdatedStringDate = lastUpdatedStringDate else { return nil }
        return DateFormats.toDate(string: lastUpdatedStringDate, output: .YYYYMMDD_HHmmssSSSSSS)
    }
    
    var oldestTransactionDate: Date? {
        guard let oldestTransactionStringDate = oldestTransactionStringDate else { return nil }
        return DateFormats.toDate(string: oldestTransactionStringDate, output: .YYYYMMDD)
    }
    
    var entitiesData: [FinancialHealthEntityRepresentable]? {
        entities
    }
}

struct FinancialHealthEntityDTO: Decodable {
    var company: String?
    var lastUpdate: String?
    var status: String?
    var type: String?
    var message: String?
}

extension FinancialHealthEntityDTO: FinancialHealthEntityRepresentable {
    var lastUpdateDate: Date? {
        guard let lastUpdateStringDate = lastUpdate else { return nil }
        return DateFormats.toDate(string: lastUpdateStringDate, output: .YYYYMMDD_T_HHmmss)
    }
}
