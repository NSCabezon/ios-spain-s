import Foundation
import CoreDomain
import OpenCombine

public protocol GetCardDetailConfigurationUseCase {
    func fetchCardDetailConfiguration(card: CardRepresentable, cardDetail: CardDetailRepresentable) -> AnyPublisher<CardDetailConfiguration, Never>
}

public struct DefaultGetCardDetailConfigurationUseCase: GetCardDetailConfigurationUseCase {
    public init() { }
    
    public func fetchCardDetailConfiguration(card: CardRepresentable, cardDetail: CardDetailRepresentable) -> AnyPublisher<CardDetailConfiguration, Never> {
        return Just(getCardDetailConfiguration(card: card, cardDetail: cardDetail))
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetCardDetailConfigurationUseCase {
    func getCardDetailConfiguration(card: CardRepresentable, cardDetail: CardDetailRepresentable) -> CardDetailConfiguration {
        let cardDetailConfiguration = CardDetailConfiguration(card: card, cardDetail: cardDetail)
        let alias = CardAliasConfiguration(isChangeAliasEnabled: true)
        cardDetailConfiguration.formatLinkedAccount = cardDetail.linkedAccount
        cardDetailConfiguration.cardAliasConfiguration = alias
        cardDetailConfiguration.creditCardHeaderElements = [.limitCredit, .availableCredit, .withdrawnCredit]
        cardDetailConfiguration.debitCardHeaderElements = [.spentThisMonth, .tradeLimit, .atmLimit]
        cardDetailConfiguration.prepaidCardHeaderElements = [.availableBalance, .spentThisMonth]
        cardDetailConfiguration.cardDetailElements = [.pan, .alias, .holder, .beneficiary, .linkedAccount, .situation, .expirationDate, .type]
        return cardDetailConfiguration
    }
      
}
