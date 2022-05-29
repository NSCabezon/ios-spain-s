//
//  ProductTypeEntity+Extension.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 29/12/21.
//

import CoreDomain

public extension ProductTypeEntity {

    static var orderDictionary: [ProductTypeEntity: Int] {
        return [
            .account: 0,
            .card: 1,
            .savingProduct: 2,
            .stockAccount: 3,
            .loan: 4,
            .deposit: 5,
            .pension: 6,
            .fund: 7,
            .notManagedPortfolio: 8,
            .managedPortfolio: 9,
            .insuranceSaving: 10,
            .insuranceProtection: 11
        ]
    }
    
    static var pbOrderDictionary: [ProductTypeEntity: Int] {
        return [
            .account: 0,
            .notManagedPortfolio: 1,
            .managedPortfolio: 2,
            .card: 3,
            .savingProduct: 4,
            .deposit: 5,
            .loan: 6,
            .stockAccount: 7,
            .pension: 8,
            .fund: 9,
            .insuranceSaving: 10,
            .insuranceProtection: 11
        ]
    }
    
    static func getOrderDictionary(isPb: Bool) -> [ProductTypeEntity: Int] {
        return isPb ? ProductTypeEntity.pbOrderDictionary: ProductTypeEntity.orderDictionary
    }
    
    static func getProductsOrdered(isPb: Bool) -> [ProductTypeEntity] {
        let dict: [ProductTypeEntity: Int] = isPb ? ProductTypeEntity.pbOrderDictionary: ProductTypeEntity.orderDictionary
        return dict.sorted(by: { $0.value < $1.value }).map({ $0.0 })
    }
    
    func getPosition(isPB: Bool) -> Int {
        return (isPB ? ProductTypeEntity.pbOrderDictionary[self]: ProductTypeEntity.orderDictionary[self]) ?? 0
    }
    
    func basketTitleKey() -> String? {
        let values: [ProductTypeEntity: String] = [
            .account: "pgBasket_title_accounts",
            .card: "pgBasket_title_cards",
            .pension: "pgBasket_title_plans",
            .fund: "pgBasket_title_funds",
            .managedPortfolio: "pgBasket_title_portfolioManaged",
            .notManagedPortfolio: "pgBasket_title_portfolioNotManaged",
            .stockAccount: "pgBasket_title_stocks",
            .deposit: "pgBasket_title_deposits",
            .loan: "pgBasket_title_loans",
            .insuranceProtection: "pgBasket_title_insurance",
            .insuranceSaving: "pgBasket_title_insuranceSaving",
            .savingProduct: "pgBasket_title_savingProducts"
        ]
        return values[self]
    }
}
