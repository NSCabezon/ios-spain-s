//
//  AccountTransactionDetailCustomActionModifierProtocol.swift
//  Account
//
//  Created by crodrigueza on 30/6/21.
//

import CoreFoundationLib

public protocol AccountTransactionDetailCustomActionModifierProtocol: AnyObject {
    func customViewTypePayBill() -> ActionButtonFillViewType
    func getPayBillAction()
}
