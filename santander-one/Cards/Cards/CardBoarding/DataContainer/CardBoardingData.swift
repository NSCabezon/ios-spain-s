//
//  CardBoardingData.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/16/20.
//

import Foundation
import CoreFoundationLib

final class CardBoardingStepTracker {
    var stepTracker: StepTracker
    
    init(card: CardEntity, paymentMethod: PaymentMethodCategory?) {
        let aliasStep = AliasTracker(alias: card.alias ?? "")
        let applePayStep = ApplePayTracker(applePayState: nil)
        let changePaymentStep = PaymentMethodTracker(paymentMethod: paymentMethod)
        self.stepTracker = StepTracker(
            aliasStep: aliasStep,
            applePayTracker: applePayStep,
            paymentMethodTracker: changePaymentStep
        )
    }
}
