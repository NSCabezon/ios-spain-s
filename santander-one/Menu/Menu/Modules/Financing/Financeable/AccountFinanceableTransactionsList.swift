//
//  AccountFinanceableTransactionsList.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 25/08/2020.
//

import Foundation
import CoreFoundationLib

final class AccountFinanceableTransactionsList {
    let account: AccountEntity
    let transactions: [EasyPayTransactionFinanceable]
    
    init(account: AccountEntity, transactions: [EasyPayTransactionFinanceable]) {
        self.account = account
        self.transactions = transactions
    }
}

extension AccountFinanceableTransactionsList: Equatable {
    static func == (lhs: AccountFinanceableTransactionsList, rhs: AccountFinanceableTransactionsList) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension AccountFinanceableTransactionsList: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.account.hashValue)
    }
}
