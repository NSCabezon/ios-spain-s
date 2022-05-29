//
//  MockCardTransaction.swift
//  Pods
//
//  Created by Hernán Villamil on 18/4/22.
//

import Foundation
import CoreDomain

struct MockCardTransaction: CardTransactionRepresentable {
    var identifier: String?
    var transactionDate: Date?
    var operationDate: Date?
    var description: String?
    var amountRepresentable: AmountRepresentable?
    var annotationDate: Date?
    var transactionDay: String?
    var balanceCode: String?
}
