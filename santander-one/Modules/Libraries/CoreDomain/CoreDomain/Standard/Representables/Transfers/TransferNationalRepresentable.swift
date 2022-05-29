//
//  TransferNationalRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 19/08/2021.
//

public protocol TransferNationalRepresentable {
    var issueDate: Date? { get }
    var destinationAccountDescription: String? { get }
    var originAccountDescription: String? { get }
    var payerName: String? { get }
    var scaRepresentable: SCARepresentable? { get }
    var bankChargeAmountRepresentable: AmountRepresentable? { get }
}

public extension TransferNationalRepresentable {
    var bankChargeAmountRepresentable: AmountRepresentable? { nil }
}
