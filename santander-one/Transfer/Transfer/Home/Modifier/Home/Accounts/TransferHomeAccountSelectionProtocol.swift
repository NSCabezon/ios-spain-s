//
//  TransferHomeAccountSelectionProtocol.swift
//  Transfer
//
//  Created by Felipe Lloret on 25/4/22.
//

import CoreFoundationLib

public protocol TransferHomeAccountSelectionProtocol {
    func checkAccounts(_ accounts: [AccountEntity]) -> AccountEntity?
}
