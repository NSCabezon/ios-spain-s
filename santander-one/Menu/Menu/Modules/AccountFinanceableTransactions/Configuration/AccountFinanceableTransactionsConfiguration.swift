//
//  AccountFinanceableTransactionsConfiguration.swift
//  Menu
//
//  Created by José Carlos Estela Anguita on 02/09/2020.
//

import Foundation
import CoreFoundationLib

public protocol AccountFinanceableTransactionConfigurationProtocol {
    var selectedAccount: AccountEntity? { get }
}

public final class AccountFinanceableTransactionConfiguration: AccountFinanceableTransactionConfigurationProtocol {
    public let selectedAccount: AccountEntity?
    
    public init(selectedAccount: AccountEntity?) {
        self.selectedAccount = selectedAccount
    }
}
