//
//  LoanTransactionActionsModifier.swift
//  Loans
//

import CoreFoundationLib
import CoreDomain

public protocol LoanTransactionActionsModifier {
    func didSelectAction(_ action: LoanTransactionDetailActionType, forTransaction transaction: LoanTransactionRepresentable, andLoan loan: LoanRepresentable) -> Bool
    
}

public extension LoanTransactionActionsModifier {
    func didSelectAction(_ action: LoanTransactionDetailActionType, forTransaction transaction: LoanTransactionRepresentable, andLoan loan: LoanRepresentable) -> Bool {
        return false
    }
}
