//
//  LoanPartialAmortizationRepresentable.swift
//  CoreDomain
//
//  Created by Juan Carlos López Robles on 12/20/21.
//

import Foundation

public protocol LoanPartialAmortizationRepresentable {
    var loanContract: String? { get }
    var userContract: String? { get }
    var getLinkedAccountContract: String? { get }
    var getExpiration: String? { get }
    var getStartLimit: AmountRepresentable? { get }
    var getActualLimit: String? { get }
    var pendingAmount: AmountRepresentable? { get }
    var linkedAccountIntContract: ContractRepresentable? { get }
    var isNewMortgageLawLoan: Bool { get }
}
