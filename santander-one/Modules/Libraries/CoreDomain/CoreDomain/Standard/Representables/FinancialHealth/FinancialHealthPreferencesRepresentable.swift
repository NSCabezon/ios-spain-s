//
//  FinancialHealthPreferencesRepresentable.swift
//  SANLibraryV3
//
//  Created by Miguel Bragado Sánchez on 10/3/22.
//

import Foundation

public protocol SetFinancialHealthPreferencesRepresentable {
    var preferencesProducts: [SetFinancialHealthPreferencesProductRepresentable]? { get }
}

public protocol SetFinancialHealthPreferencesProductRepresentable {
    var preferencesProductType: PreferencesProductType? { get }
    var preferencesData: [SetFinancialHealthPreferencesProductDataRepresentable]? { get }
}

public protocol SetFinancialHealthPreferencesProductDataRepresentable {
    var productId: String? { get }
    var productSelected: Bool? { get }
}

public enum PreferencesProductType: String, Decodable {
    case account = "accounts"
    case creditCards = "creditCards"
}
