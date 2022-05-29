//
//  LoansModifierProtocol.swift
//  Loans
//
//  Created by Iván Estévez Nieto on 30/6/21.
//

import Foundation
import CoreFoundationLib

public protocol LoansModifierProtocol {
    var waitForLoanDetail: Bool { get }
    var hideFilterButton: Bool { get }
    var transactionSortOrder: LoanTransactionsSortOrder { get }
}

public enum LoanTransactionsSortOrder {
    case mostRecent
    case lessRecent
}
