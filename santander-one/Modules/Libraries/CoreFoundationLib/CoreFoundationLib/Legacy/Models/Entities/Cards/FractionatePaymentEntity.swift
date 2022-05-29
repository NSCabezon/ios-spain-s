//
//  File.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 30/04/2020.
//

import Foundation

public protocol MontlyPaymentFeeConformable {
    /// montly fee amount
    var fee: Decimal {get set}
    /// number of months that fee apply
    var months: Int {get set}
}

public struct FractionatePaymentEntity {
    /// collection of splited payment options
    public var montlyFeeItems: [MontlyPaymentFeeEntity]
    /// Minimum amount that easyPay will apply
    public let minimumAmount: Int
    /// Maximum number of installments
    public let maxMonths: Int
    
    /// Initialice viewmodel for easypay options
    /// - Parameters:
    ///   - fractions: Easy pay options as montly fees
    ///   - minAmount: minimum int amount possible to apply easy pay
    ///   - maxMonths: max number of possible months to fraction
    public init(fractions: [MontlyPaymentFeeEntity], minAmount: Int, maxMonths: Int) {
        self.montlyFeeItems = fractions
        self.minimumAmount = minAmount
        self.maxMonths = maxMonths
    }
}

public struct MontlyPaymentFeeEntity: MontlyPaymentFeeConformable {
    /// montly fee amount
    public var fee = Decimal.zero
    /// number of months that fee apply
    public var months: Int
    public var easyPayAmortization: EasyPayAmortizationEntity?
    public var currentAmount: Decimal
    
    public init(fee: Decimal,numberOfMonths: Int, easyPayAmortization: EasyPayAmortizationEntity, currentAmount: Decimal = 0) {
        self.fee = fee
        self.months = numberOfMonths
        self.easyPayAmortization = easyPayAmortization
        self.currentAmount = currentAmount
        roundFee()
    }
    
    public init() {
        self.fee = 0.0
        self.months = 0
        self.currentAmount = 0
    }
}

extension MontlyPaymentFeeEntity {
    private func roundFee() {
        
    }
}
