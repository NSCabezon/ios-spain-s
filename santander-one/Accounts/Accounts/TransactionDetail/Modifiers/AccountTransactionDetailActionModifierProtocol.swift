//
//  AccountTransactionDetailActionModifierProtocol.swift
//  Account
//
//  Created by Carlos Monfort Gómez on 13/4/21.
//

import CoreFoundationLib

public protocol AccountTransactionDetailActionModifierProtocol: AnyObject {
    func customViewType() -> ActionButtonFillViewType
}
