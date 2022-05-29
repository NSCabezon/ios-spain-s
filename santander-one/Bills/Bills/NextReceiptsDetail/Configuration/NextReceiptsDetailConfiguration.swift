//
//  NextReceiptsDetailConfiguration.swift
//  Bills
//
//  Created by alvola on 03/06/2020.
//

import CoreFoundationLib
import CoreDomain

final class NextReceiptsDetailConfiguration {
    
    let selectedBill: AccountFutureBillRepresentable
    let bills: [AccountFutureBillRepresentable]
    let entity: AccountEntity
    
    init(_ selectedBill: AccountFutureBillRepresentable, in bills: [AccountFutureBillRepresentable], for entity: AccountEntity) {
        self.selectedBill = selectedBill
        self.bills = bills
        self.entity = entity
    }
}
