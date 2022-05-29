//
//  CardTransactionDetailConfigRepresentable.swift
//  CoreDomain
//
//  Created by Hernán Villamil on 11/4/22.
//

import Foundation

public protocol CardTransactionDetailConfigRepresentable {
    var isEnabledMap: Bool { get }
    var isSplitExpensesEnabled: Bool { get }
    var enableEasyPayCards: Bool { get }
    var isEasyPayClassicEnabled: Bool { get }
}
