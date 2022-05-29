//
//  AccountFinanceableViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 24/08/2020.
//

import Foundation
import UI
import CoreFoundationLib

struct AccountFinanceableViewModel: DropdownElement, Equatable {
    
    let account: AccountEntity
    
    var name: String {
        guard let alias = self.account.alias else { return "" }
        return alias + " | " + self.account.getIBANShort
    }
}
