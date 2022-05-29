//
//  CardBoardingWithCardsSelectorConfiguration.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 19/01/2021.
//

import CoreFoundationLib

public final class CardBoardingCardsSelectorConfiguration {
    let cards: [CardEntity]
    
    public init(cards: [CardEntity]) {
        self.cards = cards
    }
}
