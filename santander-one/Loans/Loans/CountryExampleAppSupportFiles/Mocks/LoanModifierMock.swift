//
//  LoanModifierMock.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/19/21.
//

import Foundation

public class LoanModifierMock: LoansModifierProtocol {
    public var transactionSortOrder: LoanTransactionsSortOrder = .mostRecent
    public var waitForLoanDetail: Bool = true
    public var hideFilterButton: Bool = false
            
    public init() {}
}
