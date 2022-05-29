//
//  PaymentConfiguration.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 8/4/20.
//

import Foundation

public final class PaymentConfiguration {
    let isBillEmitterPaymentEnable: Bool
    
    public init(_ isBillEmitterPaymentEnable: Bool) {
        self.isBillEmitterPaymentEnable = isBillEmitterPaymentEnable
    }
}
