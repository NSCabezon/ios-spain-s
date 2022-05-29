//
//  BillConfiguration.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/26/20.
//

import Foundation
import CoreFoundationLib

public struct BillConfiguration {
    var account: AccountEntity?
    
    public init(account: AccountEntity?) {
        self.account = account
    }
}
