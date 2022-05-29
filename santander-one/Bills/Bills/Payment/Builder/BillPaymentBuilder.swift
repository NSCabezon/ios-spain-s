//
//  BillPaymentBuilder.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 8/4/20.
//

import Foundation
import CoreFoundationLib

final class BillPaymentBuilder {
    private var payments = [PaymentViewModel]()
    private let configuration: PaymentConfiguration
    
    init(_ configuration: PaymentConfiguration) {
        self.configuration = configuration
    }
    
    func addReceipts() -> Self {
        let receipts = PaymentViewModel(
            title: localized("receiptsAndTaxes_button_receipts"),
            description: localized("receiptsAndTaxes_button_receiptsText"),
            imageName: "icnReceipts", type: .bills
        )
        self.payments.append(receipts)
        return self
    }
    
    func addTaxes() -> Self {
        let emitterPayment = PaymentViewModel(
            title: localized("receiptsAndTaxes_button_taxes"),
            description: localized("receiptsAndTaxes_text_taxes"),
            imageName: "icnTaxes",
            type: .taxes
        )
        self.payments.append(emitterPayment)
        return self
    }
    
    func addEmitterPayment() -> Self {
        guard configuration.isBillEmitterPaymentEnable else { return self }
        let emitterPayment = PaymentViewModel(
            title: localized("receiptsAndTaxes_button_otherPayment"),
            description: localized("receiptsAndTaxes_text_otherPayment"),
            imageName: "icnOtherPayments",
            type: .billPayment
        )
        self.payments.append(emitterPayment)
        return self
    }
    
    func build() -> [PaymentViewModel] {
        return self.payments
    }
}
