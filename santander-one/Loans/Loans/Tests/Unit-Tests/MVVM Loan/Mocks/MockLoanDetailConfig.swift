//
//  MockLoanDetailConfig.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 25/2/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreDomain

struct MockLoanDetailConfig: LoanDetailConfigRepresentable {
    var isEnabledFirstHolder: Bool = true
    var isEnabledInitialExpiration: Bool = true
    var aliasIsNeeded: Bool = true
    var isEnabledLastOperationDate: Bool = false
    var isEnabledNextInstallmentDate: Bool = false
    var isEnabledCurrentInterestAmount: Bool = false
    func formatLoanId(_ loanId: String) -> String { return ""}
    func formatPeriodicity(_ periodicity: String) -> String? { return nil }
}
