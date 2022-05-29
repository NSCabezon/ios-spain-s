//
//  AccountTransactionPush.swift
//  Santander
//
//  Created by Francisco del Real Escudero on 1/6/21.
//

import CoreFoundationLib

struct AccountTransactionPush: Codable, AccountTransactionPushProtocol {
    var accountName: String
    var ccc: String
    var date: String?
    var currency: String?
    var value: String?
    var amount: String?
}
