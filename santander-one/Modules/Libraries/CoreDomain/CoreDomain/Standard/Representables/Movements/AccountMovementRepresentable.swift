//
//  AccountMovementRepresentable.swift
//  CoreDomain
//
//  Created by David Gálvez Alonso on 7/12/21.
//

import Foundation

public protocol AccountMovementRepresentable {
    var operationDate: Date { get }
    var amount: Double { get }
    var balance: Double { get }
    var currency: String { get }
    var description: String { get }
    var amountRepresentable: AmountRepresentable? { get }
    var balanceRepresentable: AmountRepresentable? { get }
}
