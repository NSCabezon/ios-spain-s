//
//  CardOnOffOperativeData.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 30/8/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

final class CardOnOffOperativeData {
    var selectedCard: CardEntity?
    let option: CardBlockType
    var list = [CardEntity]()
    
    init(selectedCard: CardEntity?, option: CardBlockType) {
        self.selectedCard = selectedCard
        self.option = option
    }
}
