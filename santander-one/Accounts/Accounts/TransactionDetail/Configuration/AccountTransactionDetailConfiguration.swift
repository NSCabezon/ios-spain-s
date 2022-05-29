//
//  AccountTransactionDetailConfiguration.swift
//  Accounts
//
//  Created by Jose Carlos Estela Anguita on 20/11/2019.
//

import CoreFoundationLib

final public class AccountTransactionDetailConfiguration {
    
    var selectedAccount: AccountEntity
    var selectedTransaction: AccountTransactionEntity
    let allTransactions: [AccountTransactionEntity]
    
    var resultTransactions: [AccountTransactionWithAccountEntity]?
    
    public init(selectedAccount: AccountEntity, selectedTransaction: AccountTransactionEntity, allTransactions: [AccountTransactionEntity]) {
        self.selectedTransaction = selectedTransaction
        self.allTransactions = allTransactions
        self.selectedAccount = selectedAccount
    }
    
    public init(selectedAccount: AccountEntity, selectedTransaction: AccountTransactionEntity, resultTransactions: [AccountTransactionWithAccountEntity]) {
        self.selectedTransaction = selectedTransaction
        self.allTransactions = resultTransactions.map { $0.accountTransactionEntity }
        self.selectedAccount = selectedAccount
        self.resultTransactions = resultTransactions
    }
}
