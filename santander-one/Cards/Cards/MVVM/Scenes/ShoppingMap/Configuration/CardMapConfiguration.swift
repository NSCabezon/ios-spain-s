//
//  CardMapConfiguration.swift
//  Cards
//
//  Created by Hernán Villamil on 21/2/22.
//

import CoreDomain

public enum CardMapTypeConfiguration {
    case one(location: CardMapItemRepresentable)
    case multiple
    case date(startDate: Date, endDate: Date)
}

public final class CardMapConfiguration {
    let type: CardMapTypeConfiguration
    let card: CardRepresentable
    
    public init(type: CardMapTypeConfiguration, card: CardRepresentable) {
        self.type = type
        self.card = card
    }
}
