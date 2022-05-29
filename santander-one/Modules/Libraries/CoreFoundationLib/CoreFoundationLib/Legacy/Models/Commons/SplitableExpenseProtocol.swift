//
//  SplitableExpenseProtocol.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 12/01/2021.
//

import Foundation

public protocol SplitableExpenseProtocol {
    var amount: AmountEntity { get }
    var productAlias: String { get }
    var concept: String { get }
}
