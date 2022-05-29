//
//  LoanRepresentable.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 10/4/21.
//

import Foundation

public protocol LoanRepresentable: GlobalPositionProductIdentifiable {
    var alias: String? { get }
    var productIdentifier: String? { get }
    var contractStatusDesc: String? { get }
    var contractDescription: String? { get }
    var contractDisplayNumber: String? { get }
    var indVisibleAlias : Bool? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var typeOwnershipDesc: String? { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var currentBalanceAmountRepresentable: AmountRepresentable? { get }
    var availableAmountRepresentable: AmountRepresentable? { get }
    var counterAvailableBalanceAmountRepresentable: AmountRepresentable? { get }
    var counterCurrentBalanceAmountRepresentable: AmountRepresentable? { get }
}

// MARK: GlobalPositionProductRepresentable
public extension LoanRepresentable {
    var appIdentifier: String {
        return contractRepresentable?.formattedValue ?? ""
    }
    
    var boxType: UserPrefBoxType {
        return .loan
    }
}

public protocol LoanPdfRepresentable {
    var document: String? { get }
}
