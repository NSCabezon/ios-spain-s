//
//  CardFinanceableTransactionConfiguration.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/24/20.
//

import Foundation
import CoreFoundationLib

public final class CardFinanceableTransactionConfiguration {
    let selectedCard: CardEntity?
    
    public init(selectedCard: CardEntity?) {
        self.selectedCard = selectedCard
    }
}
