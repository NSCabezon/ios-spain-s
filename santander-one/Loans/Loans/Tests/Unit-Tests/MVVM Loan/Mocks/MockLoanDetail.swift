//
//  MockLoanDetail.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 25/2/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreDomain

struct MockLoanDetail: LoanDetailRepresentable {
    var holder: String?
    var initialAmountRepresentable: AmountRepresentable?
    var interestType: String?
    var interestTypeDesc: String?
    var feePeriodDesc: String?
    var openingDate: Date?
    var initialDueDate: Date?
    var currentDueDate: Date?
    var linkedAccountContractRepresentable: ContractRepresentable?
    var linkedAccountDesc: String?
    var revocable: Bool?
    var nextInstallmentDate: Date?
    var currentInterestAmount: String?
    var amortizable: Bool?
    var lastOperationDate: Date?
    var formatPeriodicity: String?
}
