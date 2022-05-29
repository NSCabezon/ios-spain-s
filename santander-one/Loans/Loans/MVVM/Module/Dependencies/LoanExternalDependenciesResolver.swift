//
//  Dependency+Typealias.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/25/21.
//

import Foundation

public protocol LoanExternalDependenciesResolver:
    LoanHomeExternalDependenciesResolver,
    LoanDetailExternalDependenciesResolver,
    LoanTransactionSearchExternalDependenciesResolver,
    LoanTransactionDetailExternalDependenciesResolver,
    LoanRepaymentExternalDependenciesResolver {}
