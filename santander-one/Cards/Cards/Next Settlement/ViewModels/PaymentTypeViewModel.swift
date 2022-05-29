//
//  PaymentTypeViewModel.swift
//  Pods
//
//  Created by Laura González on 13/10/2020.
//

import Foundation
import CoreFoundationLib

final class PaymentTypeViewModel {
    private var paymentMethod: CardPaymentMethodTypeEntity?
    private var paymentMethodDescription: String?
    
    init(_ paymentMethod: CardPaymentMethodTypeEntity?, paymentMethodDescription: String?) {
        self.paymentMethod = paymentMethod
        self.paymentMethodDescription = paymentMethodDescription
    }
    
    var paymentMethodLabel: LocalizedStylableText {
        let amount = getAmount(paymentMethodDescription ?? "")
        switch paymentMethod {
        case .monthlyPayment:
            return localized("nextSettlement_label_monthlyPayament")
        case .fixedFee:
            return localized("nextSettlement_label_fixedFeePayament", [StringPlaceholder(.value, amount)])
        case .deferredPayment:
            return localized("nextSettlement_label_postponePayament", [StringPlaceholder(.value, amount)])
        case .minimalPayment:
            return localized("nextSettlement_label_minPayament")
        case .immediatePayment:
            return localized("nextSettlement_label_instantPayament")
        case .none:
            return .empty
        }
    }
    
    var hideDisclaimer: Bool {
        switch paymentMethod {
        case .monthlyPayment:
            return true
        case .fixedFee:
            return false
        case .deferredPayment:
            return false
        case .minimalPayment:
            return false
        case .immediatePayment:
            return true
        case .none:
            return true
        }
    }
    
    func getAmount(_ amount: String) -> String {
        let regex = "(?:\\d+(?:\\.\\d*)?|\\.\\d+)"
        if let range = amount.range(of: regex, options: .regularExpression) {
            return String(amount[range])
        } else {
            return ""
        }
    }
}
