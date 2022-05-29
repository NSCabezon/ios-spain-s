//
//  MockSavings.swift
//  Pods
//
//  Created by Adrian Escriche on 4/4/22.
//

import Foundation
import CoreDomain

struct MockSavingProduct: SavingProductRepresentable {
    var accountId: String?
    var alias: String?
    var identification: String?
    var accountSubType: String?
    var interestRate: String?
    var interestRateLinkRepresentable: InterestRateLinkRepresentable?
    var currentBalanceRepresentable: AmountRepresentable?
    var balanceIncludedPendingRepresentable: AmountRepresentable?
    var contractRepresentable: ContractRepresentable?
    var currencyRepresentable: CurrencyRepresentable?
    var ownershipTypeDesc: OwnershipTypeDesc?
    var counterValueAmountRepresentable: AmountRepresentable?
}
