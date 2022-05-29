//
//  LoanTransactionDetailConfiguration.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 20/8/21.
//

import Foundation
import CoreFoundationLib

final class LoanTransactionDetailConfiguration {

    let selectedTransaction: LoanTransactionEntity
    let selectedLoan: LoanEntity
    let allTransactions: [LoanTransactionEntity]
        
    init(selectedTransaction: LoanTransactionEntity, selectedLoan: LoanEntity, allTransactions: [LoanTransactionEntity]) {
        self.selectedTransaction = selectedTransaction
        self.selectedLoan = selectedLoan
        self.allTransactions = allTransactions
    }
}
