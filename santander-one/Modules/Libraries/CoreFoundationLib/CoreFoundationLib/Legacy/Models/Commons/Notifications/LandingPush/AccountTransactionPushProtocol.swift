//
//  AccountTransactionPushProtocol.swift
//  Models
//
//  Created by Francisco del Real Escudero on 1/6/21.
//

import Foundation

public protocol AccountTransactionPushProtocol {
    var accountName: String { get }
    var ccc: String { get }
    var date: String? { get }
    var currency: String? { get }
    var value: String? { get }
    var amount: String? { get }
}
