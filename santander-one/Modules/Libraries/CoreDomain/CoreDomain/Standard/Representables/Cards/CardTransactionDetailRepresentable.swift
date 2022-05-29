//
//  CardTransactionDetailRepresentable.swift
//  CoreDomain
//
//  Created by Gloria Cano López on 5/4/22.
//

public protocol CardTransactionDetailRepresentable {
    var isSoldOut: Bool { get }
    var soldOutDate: Date? { get }
    var bankChargeRepresentable: AmountRepresentable? { get }
    var transactionDate: String? { get }
}
