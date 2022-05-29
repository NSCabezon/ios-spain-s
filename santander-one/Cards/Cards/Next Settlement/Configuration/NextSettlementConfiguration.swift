//
//  NextSettlementConfiguration.swift
//  Cards
//
//  Created by Laura González on 14/10/2020.
//

import CoreFoundationLib

public final class NextSettlementConfiguration {
    let card: CardEntity
    let cardSettlementDetailEntity: CardSettlementDetailEntity
    let isMultipleMapEnabled: Bool
    
    public init(card: CardEntity, cardSettlementDetailEntity: CardSettlementDetailEntity, isMultipleMapEnabled: Bool) {
        self.card = card
        self.cardSettlementDetailEntity = cardSettlementDetailEntity
        self.isMultipleMapEnabled = isMultipleMapEnabled
    }
}
