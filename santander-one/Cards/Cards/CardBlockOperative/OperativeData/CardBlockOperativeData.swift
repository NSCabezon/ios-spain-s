//
//  CardBlockOperativeData.swift
//  Cards
//
//  Created by Laura González on 27/05/2021.
//

import Foundation
import CoreFoundationLib
import CoreDomain

final class CardBlockOperativeData {
    var selectedCard: CardEntity?
    var cards: [CardEntity] = []
    var deliveryAddress: String?
    var blockReason: CardBlockReasonOption?
    var blockType: CardBlockType?
    var comment: String?
    
    init(selectedCard: CardEntity?) {
        self.selectedCard = selectedCard
    }
}
