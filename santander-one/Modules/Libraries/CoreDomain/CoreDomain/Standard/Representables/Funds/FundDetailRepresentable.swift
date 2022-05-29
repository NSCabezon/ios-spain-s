//
//  FundDetailRepresentable.swift
//  CoreDomain
//
//  Created by Ernesto Fernandez Calles on 15/3/22.
//

import Foundation

public protocol FundDetailRepresentable {
    var associatedAccountRepresentable: String? { get }
    var ownerRepresentable: String? { get }
    var descriptionRepresentable: String? { get }
    var dateOfValuationRepresentable: Date? { get }
    var numberOfunitsRepresentable: String? { get }
    var valueOfAUnitAmountRepresentable: AmountRepresentable?  { get }
    var totalValueAmountRepresentable: AmountRepresentable?  { get }
    var categoryRepresentable: String?  { get }
    var unusedIsaAllowanceRepresentable: AmountRepresentable? { get }
    var isaWrapInPlaceRepresentable: String? { get }
    var feesByDirectDebitRepresentable: String? { get }
    var dividendReinvestmentRepresentable: String? { get }
    var balanceRepresentable: AmountRepresentable? { get }
    var currentValueAmountRepresentable: AmountRepresentable? { get }
    var priceAtLastRepresentable: AmountRepresentable? { get }
    var unitsRepresentable: String? { get }
    var currentValueValueRepresentable: String? { get }
}

extension FundDetailRepresentable {
    public var associatedAccountRepresentable: String? { nil }
    public var ownerRepresentable: String? { nil }
    public var descriptionRepresentable: String? { nil }
    public var dateOfValuationRepresentable: Date? { nil }
    public var numberOfunitsRepresentable: String? { nil }
    public var valueOfAUnitAmountRepresentable: AmountRepresentable? { nil }
    public var totalValueAmountRepresentable: AmountRepresentable? { nil }
    public var categoryRepresentable: String? { nil }
    public var unusedIsaAllowanceRepresentable: AmountRepresentable? { nil }
    public var isaWrapInPlaceRepresentable: String? { nil }
    public var feesByDirectDebitRepresentable: String? { nil }
    public var dividendReinvestmentRepresentable: String? { nil }
    public var balanceRepresentable: AmountRepresentable? { nil }
    public var currentValueAmountRepresentable: AmountRepresentable? { nil }
    public var priceAtLastRepresentable: AmountRepresentable? { nil }
    public var unitsRepresentable: String? { nil }
    public var currentValueValueRepresentable: String? { nil }
}
