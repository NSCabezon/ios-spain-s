//
//  MockCardTransactionDetail.swift
//  Pods
//
//  Created by Hernán Villamil on 23/4/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

struct MockCardTransactionDetail: CardTransactionDetailRepresentable {
    var isSoldOut: Bool
    var soldOutDate: Date?
    var bankChargeRepresentable: AmountRepresentable?
    var transactionDate: String?
    
    init() {
        self.isSoldOut = true
        self.soldOutDate = Date()
        self.bankChargeRepresentable = AmountEntity(value: 0)
        self.transactionDate = "today"
    }
}
