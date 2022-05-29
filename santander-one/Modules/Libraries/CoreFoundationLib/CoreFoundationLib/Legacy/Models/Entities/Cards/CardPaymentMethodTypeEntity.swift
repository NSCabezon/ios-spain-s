//
//  CardPaymentMethodTypeEntity.swift
//  Models
//
//  Created by Laura González on 27/04/2020.
//

import Foundation
import SANLegacyLibrary

public enum CardPaymentMethodTypeEntity: String {
    case monthlyPayment = "PM"
    case fixedFee = "CF"
    case minimalPayment = "MI"
    case deferredPayment = "PA"
    case immediatePayment = "PI"
    
    public init?(_ dto: PaymentMethodType?) {
        switch dto {
        case .monthlyPayment:
            self = CardPaymentMethodTypeEntity.monthlyPayment
        case .fixedFee:
            self = CardPaymentMethodTypeEntity.fixedFee
        case .minimalPayment:
            self = CardPaymentMethodTypeEntity.minimalPayment
        case .deferredPayment:
            self = CardPaymentMethodTypeEntity.deferredPayment
        case .immediatePayment:
            self = CardPaymentMethodTypeEntity.immediatePayment
        default:
            return nil
        }
    }
}
