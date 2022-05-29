//
//  AccountFutureBillRepresentable.swift
//  CoreDomain
//
//  Created by David Gálvez Alonso on 7/12/21.
//

public protocol AccountFutureBillRepresentable {
    var account: String? { get }
    var bill:  String? { get }
    var billDateExpiry: String? { get }
    var billDateExpiryDate: Date? { get }
    var billConcept: String? { get }
    var personName: String? { get }
    var billStatusEnum: FutureBillStatus? { get }
    var billAmountRepresentable: AmountRepresentable? { get }
    func isEqualTo(_ representable: AccountFutureBillRepresentable) -> Bool
}

public enum FutureBillStatus {
    case autorized, pending, rejected
}
