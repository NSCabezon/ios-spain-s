//
//  LoanDetailRepresentable.swift
//  Loans
//
//  Created by Juan Jose Acosta on 22/2/22.
//

public protocol LoanDetailConfigRepresentable {
    var isEnabledFirstHolder: Bool { get }
    var isEnabledInitialExpiration: Bool { get }
    var aliasIsNeeded: Bool { get }
    var isEnabledLastOperationDate: Bool { get }
    var isEnabledNextInstallmentDate: Bool { get }
    var isEnabledCurrentInterestAmount: Bool { get }
}



