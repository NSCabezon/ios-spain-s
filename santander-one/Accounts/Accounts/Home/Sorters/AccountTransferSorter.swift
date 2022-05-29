//
//  AccountTransferSorter.swift
//  Account
//
//  Created by Juan Carlos López Robles on 2/6/20.
//

import Foundation
import CoreFoundationLib
import CoreDomain

final class AccountTransferSorter {
    
    func groupTransactionsByDate(_ groupedTransactions: [Date: [AccountTransactionEntity]], transaction: AccountTransactionEntity) -> [Date: [AccountTransactionEntity]] {
        var groupedTransactions = groupedTransactions
        guard let operationDate = transaction.operationDate else { return groupedTransactions }
        guard
            let dateByDay = groupedTransactions.keys.first(where: { $0.isSameDay(than: operationDate) }),
            let transactionsByDate = groupedTransactions[dateByDay]
            else {
                groupedTransactions[operationDate.startOfDay()] = [transaction]
                return groupedTransactions
        }
        groupedTransactions[dateByDay] = transactionsByDate + [transaction]
        return groupedTransactions
    }
    
    func groupeBillByDate(_ groupedBills: [Date: [AccountFutureBillRepresentable]], bill: AccountFutureBillRepresentable) -> [Date: [AccountFutureBillRepresentable]] {
        var groupedBills = groupedBills
        guard let operationDate = bill.billDateExpiryDate else { return groupedBills }
        if let dateByDay = groupedBills.keys.first(where: { $0.isSameDay(than: operationDate) }),
            let billsByDate = groupedBills[dateByDay] {
            groupedBills[dateByDay] = billsByDate + [bill]
            return groupedBills
        } else {
            groupedBills[operationDate.startOfDay()] = [bill]
            return groupedBills
        }
    }
}
