//
//  DirectDebitConfiguration.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 07/04/2020.
//

import Foundation
import CoreFoundationLib

public struct DirectDebitConfiguration {
    let account: AccountEntity?
    
    public init(account: AccountEntity?) {
        self.account = account
    }
}
