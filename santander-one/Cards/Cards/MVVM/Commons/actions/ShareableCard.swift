//
//  ShareableCard.swift
//  Pods
//
//  Created by Hernán Villamil on 22/4/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

final class ShareableCard {
    private let card: CardRepresentable
    
    init(card: CardRepresentable) {
        self.card = card
    }
}

extension ShareableCard: Shareable {
    public func getShareableInfo() -> String {
        return card.detailUI ?? ""
    }
}
