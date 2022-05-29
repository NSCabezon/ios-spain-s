//
//  FinanceableTransaction.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/26/20.
//

import Foundation

public final class FinanceableTransaction {
    public let transaction: CardTransactionEntity
    public var fractionatedPayment: FractionatePaymentEntity?
    public var easyPayOperativeData: EasyPayOperativeDataEntity?
    
    public init(transaction: CardTransactionEntity) {
        self.transaction = transaction
    }
}
