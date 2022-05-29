//
//  CardBoardingConfiguration.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/7/20.
//

import Foundation
import CoreFoundationLib

public final class CardboardingConfiguration {
    let selectedCard: CardEntity
    var paymentMethod: ChangePaymentEntity?
    var applePayState: CardApplePayState = .notSupported
    var pushNotificationEnabled: Bool = false
    var geolocationEnabled: Bool = false
    var allowSteps: [Step] = []
    enum Step: String {
            case changeAlias
            case inApp
            case changePaymentType
            case changeCardLimits
            case notifications
            case geolocation
    }
    
    public init(card: CardEntity) {
        self.selectedCard = card
    }
}
