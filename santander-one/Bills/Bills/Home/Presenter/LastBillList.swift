//
//  LastBillList.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/18/20.
//

import Foundation
import CoreFoundationLib

final class LastBillList {
    var bills: [AccountEntity: [LastBillEntity]] = [:]
    var fromDate: Date = Date()
    var months: Int = 0
    
    func set(fromDate: Date) {
        self.fromDate = fromDate
    }
    
    func set(months: Int) {
        self.months = months
    }
    
    func append(content: [AccountEntity: [LastBillEntity]]) {
        self.bills = content.reduce(into: self.bills) { currentBills, newBills in
            let billsForAccount = currentBills[newBills.key] ?? []
            currentBills[newBills.key] = billsForAccount + newBills.value
        }
    }
}
