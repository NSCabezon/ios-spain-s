//
//  ValidationSwiftRepresentable.swift
//  CoreDomain
//
//  Created by Juan Diego Vázquez Moreno on 25/1/22.
//

public protocol ValidationSwiftRepresentable {
    var settlementAmountPayerRepresentable: AmountRepresentable? { get }
    var chargeAmountRepresentable: AmountRepresentable? { get }
    var accountType: String? { get }
    var modifyDate: Date? { get }
    var beneficiaryBic: String? { get }
    var swiftIndicator: Bool? { get }
}
