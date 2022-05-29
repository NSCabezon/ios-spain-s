//
//  SpainCardTransactionDetailActionsModifier.swift
//  Santander
//
//  Created by Laura Gonzalez Salvador on 14/9/21.
//

import Foundation
import Cards

final class SpainCardTransactionDetailActionsModifier: CardTransactionDetailActionsEnabledModifierProtocol {
    var shareAction: Bool = true
    var directMoneyAction: Bool = true
}
