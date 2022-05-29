//
//  PaymentMethodEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 14/10/2020.
//

import Foundation
import SANLegacyLibrary

public enum PaymentMethodCategory: Equatable {
    case monthlyPayment
    case fixedFee(AmountEntity?)
    case deferredPayment(AmountEntity?)
    
    public init?(_ dto: PaymentMethodType, _ amount: AmountEntity?) {
        switch dto {
        case .monthlyPayment:
            self = PaymentMethodCategory.monthlyPayment
        case .fixedFee:
            self = PaymentMethodCategory.fixedFee(amount)
        case .deferredPayment:
            self = PaymentMethodCategory.deferredPayment(amount)
        default:
            return nil
        }
    }
    
    public func value() -> AmountEntity? {
        switch self {
        case .monthlyPayment:
          return nil
        case .fixedFee(let value):
          return value
        case .deferredPayment(let value):
          return value
        }
    }
    
    public static func == (lhs: PaymentMethodCategory, rhs: PaymentMethodCategory) -> Bool {
        switch (lhs, rhs) {
        case (.monthlyPayment, .monthlyPayment):
            return true
        case (let .fixedFee(lhsAmount), let .fixedFee(rhsAmount)):
            return lhsAmount?.value == rhsAmount?.value
        case (let .deferredPayment(lhsAmount), let .deferredPayment(rhsAmount)):
            return lhsAmount?.value == rhsAmount?.value
        default:
            return false
        }
    }
}

final public class PaymentMethodEntity: DTOInstantiable {
    public let dto: PaymentMethodDTO
    
    public init(_ dto: PaymentMethodDTO) {
        self.dto = dto
    }
    
    public var idRangeFP: String? {
        return self.dto.idRangeFP
    }
    
    public var liquidationType: String? {
        return self.dto.liquidationType
    }
    
    public var paymentMethod: PaymentMethodType? {
        return self.dto.paymentMethod
    }
    
    public var paymentMethodStatus: PaymentMethodType? {
        if let status = self.dto.paymentMethod {
            switch status {
            case .monthlyPayment:
                return .monthlyPayment
            case .fixedFee:
                return .fixedFee
            case .minimalPayment:
                return .minimalPayment
            case .deferredPayment:
                return .deferredPayment
            case .immediatePayment:
                return .immediatePayment
            }
        }
        return nil
    }
    
    public var paymentMethodCategory: PaymentMethodCategory? {
        if let status = self.dto.paymentMethod {
            switch status {
            case .monthlyPayment:
                return .monthlyPayment
            case .fixedFee:
                return .fixedFee(feeAmount)
            case .deferredPayment:
                return .deferredPayment(feeAmount)
            default:
                return nil
            }
        }
        return nil
    }
    
    public var paymentMethodDesc: String? {
        return self.dto.paymentMethodDesc
    }
    
    public var thresholdDesc: Decimal? {
        return self.dto.thresholdDesc
    }
    
    public var feeAmount: AmountEntity? {
        guard let feeAmountDTO = self.dto.feeAmount else { return nil }
        return AmountEntity(feeAmountDTO)
    }
    
    public var incModeAmount: AmountEntity? {
        guard let incModeAmountDTO = self.dto.incModeAmount else { return nil }
        return AmountEntity(incModeAmountDTO)
    }
    
    public var maxModeAmount: AmountEntity? {
        guard let maxModeAmountDTO = self.dto.maxModeAmount else { return nil }
        return AmountEntity(maxModeAmountDTO)
    }
    
    public var minAmortAmount: AmountEntity? {
        guard let minAmortAmountDTO = self.dto.minAmortAmount else { return nil }
        return AmountEntity(minAmortAmountDTO)
    }
    
    public var minModeAmount: AmountEntity? {
        guard let minModeAmountDTO = self.dto.minModeAmount else { return nil }
        return AmountEntity(minModeAmountDTO)
    }
    
    // ! Get Amount Range
    public func getRangeAmount() -> [Int] {
        guard let inc = incModeAmount?.value, inc > 0,
            let max = maxModeAmount?.value, max > 0,
            let min = minModeAmount?.value else { return [] }
        return getRange(minimum: min, maximum: max, increment: inc)
    }
    
    // ! Get Percentage Range
    public func getRangePercentage() -> [Int] {
        guard let inc = incModeAmount?.value, inc > 0,
            let max = maxModeAmount?.value, max > 0,
            let min = minModeAmount?.value else { return [] }
        return (getRange(minimum: min, maximum: max, increment: inc))
    }
    
    public func getAmountByIndex(index: Int) -> Int {
        return self.getRangeAmount()[index]
    }
    
    public func getPercentageByIndex(index: Int) -> Int {
        let percentage = self.getRangePercentage()
        return percentage[index]
    }
}

private extension PaymentMethodEntity {
    // Get the array from minimum to maximum by increment
    func getRange(minimum: Decimal, maximum: Decimal, increment: Decimal) -> [Int] {
        var intArray = [Int]()
        for index in stride(from: Int(truncating: NSDecimalNumber(decimal: minimum)), through: Int(truncating: NSDecimalNumber(decimal: maximum)), by: Int(truncating: NSDecimalNumber(decimal: increment))) {
            intArray.append(index)
        }
        return intArray
    }
    
    func isNumeric(string: String) -> Bool {
        if string.rangeOfCharacter(from: .decimalDigits) != nil {
            return true
        }
        return false
    }
    
}
