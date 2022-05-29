//
//  TransferConfirmAccountRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 19/08/2021.
//

public protocol TransferConfirmAccountRepresentable {
    var destinationAccountDescription: String? { get }
    var originAccountDescription: String? { get }
    var payerName: String? { get }
    var issueDate: Date? { get }
    var referenceRepresentable: ReferenceRepresentable? { get }
}

public extension TransferConfirmAccountRepresentable {
    var referenceRepresentable: ReferenceRepresentable? {
        nil
    }
}
