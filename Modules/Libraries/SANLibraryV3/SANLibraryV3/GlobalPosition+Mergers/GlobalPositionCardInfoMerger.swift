//
//  GlobalPositionCardUpdate.swift
//  Account
//
//  Created by Juan Carlos López Robles on 3/30/22.
//

import Foundation
import SANLegacyLibrary

struct GlobalPositionCardInfoMerger {
    private let bsanDataProvider: BSANDataProvider
    private var globalPosition: GlobalPositionDTO
    private let cardInfo: CardInfo
    
    init(bsanDataProvider: BSANDataProvider) throws {
        self.bsanDataProvider = bsanDataProvider
        self.globalPosition = try bsanDataProvider.get(\.globalPositionDTO)
        self.cardInfo = try bsanDataProvider.get(\.cardInfo)
        updateGlobalPositionWithCardInfo()
    }
    
    private func updateGlobalPositionWithCardInfo() {
        let cardData = cardInfo.cardsData
        let cardBalance = cardInfo.cardBalances
        let temporallyOff = cardInfo.temporallyOffCards
        let inactiveCards = cardInfo.inactiveCards
        var globalPositionWithUpdate = self.globalPosition
        let isPB = try? bsanDataProvider.isPB()
    
        globalPositionWithUpdate.cards = [CardDTO]()
        
        for var card in globalPosition.cards ?? [] {
            let pan = card.formattedPAN ?? ""
            card.dataDTO = cardData[pan]
            card.cardBalanceDTO = cardBalance[pan]
            card.temporallyOff = temporallyOff[pan] != nil
            card.inactive = inactiveCards[pan] != nil
            globalPositionWithUpdate.cards?.append(card)
        }
        
        globalPositionWithUpdate.isPb = isPB
        self.bsanDataProvider.updateSessionData(globalPositionWithUpdate, isPB ?? false)
    }
}
