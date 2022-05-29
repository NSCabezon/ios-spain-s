//
//  LoanTransactionRepresentable.swift
//  CoreDomain
//
//  Created by Juan Carlos López Robles on 10/19/21.
//

import Foundation

public protocol BankOperationRepresentable {
    var basicOperation: String? { get }
    var bankOperation: String? { get }
}

public protocol DGONumberRepresentable {
    var number: String? { get }
    var terminalCode: String? { get }
    var center: String? { get }
    var company: String? { get }
    var description: String? { get }
}

public protocol LoanTransactionRepresentable: UniqueIdentifiable  {
    var operationDate: Date? { get }
    var amountRepresentable: AmountRepresentable? { get }
    var description: String? { get }
    var bankOperationRepresentable: BankOperationRepresentable? { get }
    var balanceRepresentable: AmountRepresentable? { get }
    var dgoNumberRepresentable: DGONumberRepresentable? { get }
    var titular: String? { get }
    var valueDate: Date? { get }
    var transactionNumber: String? { get }
    var receiptId: String? { get }
}

public extension LoanTransactionRepresentable {
    var receiptId: String? {
        nil
    }
}

extension LoanTransactionRepresentable {
    public var uniqueIdentifier: Int {
        var hasher = Hasher()
        hasher.combine(dgoNumberRepresentable?.description)
        hasher.combine(transactionNumber)
        hasher.combine(description)
        hasher.combine(amountRepresentable?.value)
        return hasher.finalize()
    }
}

