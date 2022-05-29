//
//  LastBillResponse.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/18/20.
//

import Foundation
import CoreFoundationLib

struct LastBillResponse {
    let accountBills: [AccountEntity: [LastBillEntity]]
    let fromDate: Date
    let allowMoreRequest: Bool
    let months: Int
}
