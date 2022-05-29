//
//  AccountsHomeConfiguration.swift
//  Accounts
//
//  Created by Jose Carlos Estela Anguita on 07/11/2019.
//

import CoreFoundationLib

public final class AccountsHomeConfiguration {
    
    let selectedAccount: AccountEntity?
    let isScaForTransactionsEnabled: Bool
    
    public init(selectedAccount: AccountEntity?, isScaForTransactionsEnabled: Bool) {
        self.selectedAccount = selectedAccount
        self.isScaForTransactionsEnabled = isScaForTransactionsEnabled
    }
}
