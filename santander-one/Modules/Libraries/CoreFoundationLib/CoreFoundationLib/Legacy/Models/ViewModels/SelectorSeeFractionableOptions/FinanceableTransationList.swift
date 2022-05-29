//
//  FinanceableTransationList.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/26/20.
//

import Foundation

public final class FinanceableTransationList {
    public let card: CardEntity
    public var transations: [FinanceableTransaction] = []
    
    public init(card: CardEntity, transations: [FinanceableTransaction]) {
        self.card = card
        self.transations = transations
    }
}

extension FinanceableTransationList: Equatable {
    public static func == (lhs: FinanceableTransationList, rhs: FinanceableTransationList) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension FinanceableTransationList: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.card.hashValue)
    }
}
