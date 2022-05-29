//
//  LoanDetailRepresentable.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/11/21.
//

import Foundation

public protocol LoanDetailRepresentable {
    var holder: String? { get }
    var initialAmountRepresentable: AmountRepresentable? { get }
    var interestType: String? { get }
    var interestTypeDesc: String? { get }
    var feePeriodDesc: String? { get }
    var openingDate: Date? { get }
    var initialDueDate: Date? { get }
    var currentDueDate: Date? { get }
    var linkedAccountContractRepresentable: ContractRepresentable? { get }
    var linkedAccountDesc: String? { get }
    var revocable: Bool? { get }
    var nextInstallmentDate: Date? { get }
    var currentInterestAmount: String? { get }
    var amortizable: Bool? { get }
    var lastOperationDate: Date? { get }
    var formatPeriodicity: String? { get }
}
