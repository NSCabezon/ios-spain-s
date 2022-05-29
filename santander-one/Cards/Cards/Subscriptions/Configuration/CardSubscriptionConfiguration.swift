//
//  CardSubscriptionConfiguration.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 24/02/2021.
//

import CoreFoundationLib

public enum ShowCardSubscriprionFromView {
    case general
    case card
}

public final class CardSubscriptionConfiguration {
    let selectedCard: CardEntity?
    
    public init(card: CardEntity?) {
        self.selectedCard = card
    }
}
