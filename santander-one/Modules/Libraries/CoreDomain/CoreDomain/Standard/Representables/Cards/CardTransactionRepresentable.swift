//
//  CardTrasactionsRepresentable.swift
//  Cards-Cards
//
//  Created by Gloria Cano López on 14/12/21.
//

import Foundation

public protocol CardTransactionRepresentable {
    var identifier: String? { get }
    var transactionDate: Date? { get }
    var operationDate: Date? { get }
    var description: String?{ get }
    var amountRepresentable: AmountRepresentable? { get }
    var annotationDate: Date? { get }
    var transactionDay: String? { get }
    var balanceCode: String?  { get }
}
