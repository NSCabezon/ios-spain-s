//
//  EmptyLoan.swift
//  ExampleAppTests
//
//  Created by Juan Carlos López Robles on 11/6/21.
//  Copyright © 2021 Jose Carlos Estela Anguita. All rights reserved.
//

import Foundation
import CoreDomain

struct MockLoan: LoanRepresentable {
    var alias: String?
    var productIdentifier: String?
    var contractStatusDesc: String?
    var contractDescription: String?
    var indVisibleAlias: Bool?
    var contractRepresentable: ContractRepresentable?
    var typeOwnershipDesc: String?
    var currencyRepresentable: CurrencyRepresentable?
    var currentBalanceAmountRepresentable: AmountRepresentable?
    var availableAmountRepresentable: AmountRepresentable?
    var counterAvailableBalanceAmountRepresentable: AmountRepresentable?
    var counterCurrentBalanceAmountRepresentable: AmountRepresentable?
    var contractDisplayNumber: String?
}
