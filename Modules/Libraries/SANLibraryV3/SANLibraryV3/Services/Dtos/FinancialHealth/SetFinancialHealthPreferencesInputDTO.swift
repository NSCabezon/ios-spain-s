//
//  SetFinancialHealthPreferencesInputDTO.swift
//  SANLibraryV3
//
//  Created by Miguel Bragado Sánchez on 16/3/22.
//

import Foundation

import Foundation
import CoreDomain

struct SetFinancialHealthPreferencesInputDTO: Codable {
    let products: [SetFinancialHealthPreferencesProductInputDTO]?

    init? (_ representable: SetFinancialHealthPreferencesRepresentable) {
        self.products = representable.preferencesProducts?.map { SetFinancialHealthPreferencesProductInputDTO($0) }
    }
}

struct SetFinancialHealthPreferencesProductInputDTO: Codable {
    let productType: String?
    let data: [SetFinancialHealthPreferencesProductDataInputDTO]?

    init (_ representable: SetFinancialHealthPreferencesProductRepresentable) {
        self.productType = representable.preferencesProductType?.rawValue
        self.data = representable.preferencesData?.map { SetFinancialHealthPreferencesProductDataInputDTO($0) }
    }
}

struct SetFinancialHealthPreferencesProductDataInputDTO: Codable {
    let id: String?
    let selected: Bool?

    init (_ representable: SetFinancialHealthPreferencesProductDataRepresentable) {
        self.id = representable.productId
        self.selected = representable.productSelected
    }
}
