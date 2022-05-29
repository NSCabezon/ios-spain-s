//
//  UserPrefBoxType+Extension.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 29/12/21.
//

import CoreDomain

public extension UserPrefBoxType {
    var asProductType: ProductTypeEntity {
        let conversions: [UserPrefBoxType: ProductTypeEntity] = [
            .account: .account,
            .card: .card,
            .pension: .pension,
            .fund: .fund,
            .managedPortfolio: .managedPortfolio,
            .notManagedPortfolio: .notManagedPortfolio,
            .stock: .stockAccount,
            .deposit: .deposit,
            .loan: .loan,
            .insuranceProtection: .insuranceProtection,
            .insuranceSaving: .insuranceSaving,
            .managedPortfolioVariableIncome: .managedPortfolioVariableIncome,
            .notManagedPortfolioVariableIncome: .notManagedPortfolioVariableIncome,
            .savingProduct: .savingProduct
        ]
        return conversions[self]!
    }
}
