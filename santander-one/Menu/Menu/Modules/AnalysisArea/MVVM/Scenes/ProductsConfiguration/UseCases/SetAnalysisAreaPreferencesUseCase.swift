//
//  GetAnalysisAreaPreferencesUseCase.swift
//  Menu
//
//  Created by Miguel Bragado Sánchez on 10/3/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol SetAnalysisAreaPreferencesUseCase {
    func fetchSetFinancialPreferencesPublisher(preferences: SetFinancialHealthPreferencesRepresentable) -> AnyPublisher<Void, Error>
}

struct DefaultGetAnalysisAreaPreferencesUseCase {
    private let repository: FinancialHealthRepository
    
    init(dependencies: AnalysisAreaProductsConfigurationDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultGetAnalysisAreaPreferencesUseCase: SetAnalysisAreaPreferencesUseCase {
    func fetchSetFinancialPreferencesPublisher(preferences: SetFinancialHealthPreferencesRepresentable) -> AnyPublisher<Void, Error> {
        self.repository.getFinancialPreferences(preferences: preferences)
    }
}

struct PreferencesInput: SetFinancialHealthPreferencesRepresentable {
    var preferencesProducts: [SetFinancialHealthPreferencesProductRepresentable]? { products }
    var products: [PreferencesProductInput] = []
    
    init (products: [ProductListConfigurationRepresentable]) {
        var accountsProductData: [PreferencesProductDataInput] = []
        products.filter { $0.type == .accounts ||  $0.type == .otherAccounts }.forEach { $0.products?.forEach({ product in
            accountsProductData.append(PreferencesProductDataInput(id: product.productId, selected: product.selected))
        })}
        var cardsProductData: [PreferencesProductDataInput] = []
        products.filter { $0.type == .cards ||  $0.type == .otherCards }.forEach { $0.products?.forEach({ product in
            cardsProductData.append(PreferencesProductDataInput(id: product.productId, selected: product.selected))
        })}
        if accountsProductData.isNotEmpty {
            let accounts = PreferencesProductInput(productType: .accounts, data: accountsProductData)
            self.products.append(accounts)
        }
        if cardsProductData.isNotEmpty {
            let cards = PreferencesProductInput(productType: .cards, data: cardsProductData)
            self.products.append(cards)
        }
    }
}

struct PreferencesProductInput: SetFinancialHealthPreferencesProductRepresentable {
    var preferencesProductType: PreferencesProductType? {
        switch self.productType {
        case .accounts, .otherAccounts:
            return .account
        case .cards, .otherCards:
            return .creditCards
        default:
            return nil
        }
    }
    var preferencesData: [SetFinancialHealthPreferencesProductDataRepresentable]? { data }
    var productType: ProductTypeConfiguration?
    var data: [PreferencesProductDataInput]?
    
    init (product: ProductListConfigurationRepresentable) {
        if product.type != .otherBanks {
            self.productType = product.type
            self.data = product.products?.map { PreferencesProductDataInput(id: $0.productId, selected: $0.selected) }
        }
    }
    
    init(productType: ProductTypeConfiguration, data: [PreferencesProductDataInput]) {
        self.productType = productType
        self.data = data
    }
}

struct PreferencesProductDataInput: SetFinancialHealthPreferencesProductDataRepresentable {
    var productId: String? { id }
    var productSelected: Bool? { selected }
    var id: String?
    var selected: Bool?
    
    init (id: String?, selected: Bool?) {
        self.id = id
        self.selected = selected
    }
}
