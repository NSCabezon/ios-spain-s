//
//  EasyPayContractTransactionRepresentable.swift
//  Cards
//
//  Created by Gloria Cano López on 6/4/22.
//

public protocol EasyPayContractTransactionRepresentable {
    var operationDate: Date? { get }
    var amount: AmountRepresentable? { get }
    var transactionDay: String? { get }
    var balanceCode: String? { get }
}
