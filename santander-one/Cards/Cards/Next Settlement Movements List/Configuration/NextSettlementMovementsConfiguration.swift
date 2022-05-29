//
//  NextSettlementMovementsConfiguration.swift
//  Cards
//
//  Created by David Gálvez Alonso on 16/10/2020.
//

import CoreFoundationLib

final class NextSettlementMovementsConfiguration {
    let card: CardEntity
    let nextSettlementViewModel: NextSettlementViewModel?
    
    init(card: CardEntity, nextSettlementViewModel: NextSettlementViewModel?) {
        self.card = card
        self.nextSettlementViewModel = nextSettlementViewModel
    }
}
