//
//  LoanValidationRepresentable.swift
//  CoreDomain
//
//  Created by Juan Carlos López Robles on 12/20/21.
//

import Foundation

public protocol LoanValidationRepresentable {
    var signatureRepresentable: SignatureRepresentable? { get }
    var settlementAmountRepresentable: AmountRepresentable? { get }
    var finantialLossAmountRepresentable: AmountRepresentable? { get }
    var compensationAmountRepresentable: AmountRepresentable? { get }
    var insuranceFeeAmountRepresentable: AmountRepresentable? { get }
}
