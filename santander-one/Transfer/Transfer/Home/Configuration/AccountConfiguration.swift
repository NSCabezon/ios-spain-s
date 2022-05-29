//
//  TransfersHomeConfiguration.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/20/19.
//
import CoreFoundationLib

public final class TransfersHomeConfiguration {
    
    public let selectedAccount: AccountEntity?
    let isScaForTransactionsEnabled: Bool
    
    public init(selectedAccount: AccountEntity?, isScaForTransactionsEnabled: Bool) {
        self.selectedAccount = selectedAccount
        self.isScaForTransactionsEnabled = isScaForTransactionsEnabled
    }
}
