//
//  AccountTransactionDetailActionProtocol.swift
//  Account
//

import CoreFoundationLib

public protocol AccountTransactionDetailActionProtocol {
    func getTransactionActions(for transaction: AccountTransactionEntity) -> [AccountTransactionDetailAction]?
    func showComingSoonToast() -> Bool
    func didSelectAction(_ action: AccountTransactionDetailAction, for transaction: AccountTransactionEntity) -> Bool
}

public extension AccountTransactionDetailActionProtocol {
    func didSelectAction(_ action: AccountTransactionDetailAction, for transaction: AccountTransactionEntity) -> Bool {
        return false
    }
}
