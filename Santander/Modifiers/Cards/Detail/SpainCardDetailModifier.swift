//
//  SpainCardDetailModifier.swift
//  Santander
//
//  Created by Iván Estévez Nieto on 11/8/21.
//

import Foundation
import Cards
import CoreFoundationLib

final class SpainCardDetailModifier: CardDetailModifierProtocol {
    var isCardHolderEnabled: Bool = true
    var isChangeAliasEnabled: Bool = true
    var prepaidCardHeaderElements: [PrepaidCardHeaderElements] = [.availableBalance, .spentThisMonth]
    var debitCardHeaderElements: [DebitCardHeaderElements] = [.spentThisMonth, .tradeLimit, .atmLimit]
    var creditCardHeaderElements: [CreditCardHeaderElements] = [.limitCredit, .availableCredit, .withdrawnCredit]
    func formatLinkedAccount(_ linkedAccount: String?) -> String? {
        return linkedAccount
    }
    func showCardPAN(card: CardEntity) {
        return
    }
    func isCardPANMasked(cardId: String) -> Bool {
        return false
    }
    func getCardPAN(cardId: String) -> String? {
        return nil
    }
    func getCardDetailElements(for card: CardEntity) -> [CardDetailDataType] {
        return [.pan, .alias, .holder, .beneficiary, .linkedAccount, .situation, .expirationDate, .type]
    }
}
