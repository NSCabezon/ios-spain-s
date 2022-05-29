//
//  LastBillDetail.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/26/20.
//

import Foundation
import CoreFoundationLib

public struct LastBillDetail {
    public let bill: LastBillEntity
    public let account: AccountEntity
    
    public init(bill: LastBillEntity, account: AccountEntity) {
        self.bill = bill
        self.account = account
    }
}
