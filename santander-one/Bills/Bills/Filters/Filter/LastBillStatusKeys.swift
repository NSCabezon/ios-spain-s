//
//  LastBillStatusKeys.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/20/20.
//

import Foundation
import CoreFoundationLib

struct LastBillStatusKeys {
    let billStatus: LastBillStatus
    
    func allValues() -> [String] {
        return LastBillStatus.allCases.map { localized($0.description) }
    }
    
    func selectedItem() -> Int {
        return LastBillStatus.allCases.firstIndex(of: billStatus) ?? 0
    }
}
