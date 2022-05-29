//
//  SavingsTransactionListPdfHeaderInfo.swift
//  RetailLegacy
//
//  Created by Julio Nieto Santiago on 30/4/22.
//

import Foundation

struct SavingsTransactionListPdfHeaderInfo {
    let accountNumber: String
    let fromDate: Date?
    let toDate: Date?
    
    init(accountNumber: String, fromDate: Date?, toDate: Date?) {
        self.accountNumber = accountNumber
        self.fromDate = fromDate
        self.toDate = toDate
    }
}
