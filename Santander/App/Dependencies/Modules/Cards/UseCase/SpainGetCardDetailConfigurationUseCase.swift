//
//  SpainGetCardDetailConfigurationUseCase.swift
//  Santander
//
//  Created by Gloria Cano López on 7/3/22.
//

import CoreFoundationLib
import Cards
import CoreDomain
import Foundation
import OpenCombine

struct SpainGetCardDetailConfigurationUseCase {}

extension SpainGetCardDetailConfigurationUseCase: GetCardDetailConfigurationUseCase {
    public func fetchCardDetailConfiguration(card: CardRepresentable, cardDetail: CardDetailRepresentable) -> AnyPublisher<CardDetailConfiguration, Never> {
        return Just(getCardDetailConfiguration(card: card, cardDetail: cardDetail))
                    .eraseToAnyPublisher()
    }
}

private extension SpainGetCardDetailConfigurationUseCase {
    func getCardDetailConfiguration(card: CardRepresentable, cardDetail: CardDetailRepresentable) -> CardDetailConfiguration {
        let cardDetailConfiguration = CardDetailConfiguration(card: card, cardDetail: cardDetail)
        let alias = CardAliasConfiguration(isChangeAliasEnabled: true)
        cardDetailConfiguration.formatLinkedAccount = cardDetail.linkedAccount
        cardDetailConfiguration.formatLinkeWithCreditCardAccountNumber = cardDetail.creditCardAccountNumber
        cardDetailConfiguration.isCardPANMasked = false
        cardDetailConfiguration.cardAliasConfiguration = alias
        cardDetailConfiguration.isCardHolderEnabled = true
        cardDetailConfiguration.creditCardHeaderElements = [.limitCredit, .availableCredit, .withdrawnCredit]
        cardDetailConfiguration.debitCardHeaderElements = [.spentThisMonth, .tradeLimit, .atmLimit]
        cardDetailConfiguration.prepaidCardHeaderElements = [.availableBalance, .spentThisMonth]
        cardDetailConfiguration.cardDetailElements = [.pan, .alias, .holder, .beneficiary, .linkedAccount, .situation, .expirationDate, .type]
        return cardDetailConfiguration
    }
}
