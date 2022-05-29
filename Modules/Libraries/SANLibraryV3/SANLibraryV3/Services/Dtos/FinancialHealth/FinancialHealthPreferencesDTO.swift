//
//  FinancialHealthPreferencesDTO.swift
//  SANLibraryV3
//
//  Created by Miguel Bragado Sánchez on 10/3/22.
//

import Foundation
import CoreDomain

struct FinancialHealthPreferencesDTO: Codable {
    let products: [FinancialHealthPreferencesProductDTO]?
}

struct FinancialHealthPreferencesProductDTO: Codable {
    let productType: String?
    let data: [FinancialHealthPreferencesProductDataDTO]?
}

struct FinancialHealthPreferencesProductDataDTO: Codable {
    let id: String?
    let selected: Bool?
}
