//
//  CardsSubscriptionsViewModel.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 01/03/2021.
//

import CoreFoundationLib

public struct CardSubscriptionViewModel {
    private var cardSubscriptionEntity: CardSubscriptionEntityRepresentable
    private var cardEntity: CardEntity?
    private var baseUrl: String?
    let logoColor: UIColor
    var corpImageURL: String?
    var cardImageUrl: String?
    var isSubscriptionPaymentEnabled: Bool
    var cardSubscriptionType: CardSubscriptionSeeMoreType?
    var isM4MactiveSuscriptionEnabled: Bool
    var isActiveSwitch: Bool?

    var businessName: String {
        cardSubscriptionEntity.providerName
    }
    
    var cardSubscription: CardSubscriptionEntityRepresentable {
        return cardSubscriptionEntity
    }
    
    var isFractionable: Bool {
        return cardSubscriptionEntity.isFractionable
    }
    
    var card: CardEntity? {
        return cardEntity ?? nil
    }

    var initials: String {
        self.cardSubscriptionEntity.providerName.nameInitials
    }
    
    var isActive: Bool {
        return cardSubscriptionEntity.active
    }
    
    var cardAlias: NSAttributedString? {
        guard let cardEntity = self.cardEntity else {
            return nil
        }
        return NSMutableAttributedString(string: (cardEntity.alias ?? ""),
                                  attributes: [.font: UIFont.santander(type: .bold,
                                                                       size: 16.0)])
    }
    
    var cardNumber: NSAttributedString? {
        guard let cardEntity = self.cardEntity else {
            return nil
        }
        return NSMutableAttributedString(string: " | " + cardEntity.shortContract,
                                  attributes: [.font: UIFont.santander(size: 16.0)])
    }
        
    var amountAttributeString: NSAttributedString? {
        let amount = subscriptionAmount ?? AmountEntity(value: 0.0)
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 26)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 20.0)
        return card == nil
            ? decorator.getFormatedAbsWith1M()
            : decorator.getFormatedCurrency()
    }
    
    var subscriptionDate: String? {
        return dateToString(date: cardSubscriptionEntity.lastStateChangeDate, outputFormat: .d_MMM_yyyy)
    }
    
    var subscriptionAmount: AmountEntity? {
        cardSubscriptionEntity.amount
    }
    
    var cardName: String? {
        cardEntity?.alias?.camelCasedString
    }
    
    var cardCode: String? {
        guard let card = self.cardEntity else {
            return nil
        }
        return card.trackId.camelCasedString + " | " + card.shortContract
    }

    var instaId: String? {
        self.cardSubscriptionEntity.instaId
    }

    var fromViewType: ShowCardSubscriprionFromView
    
    var transactionViewModel: CardListFinanceableTransactionViewModel?
    
    var isSeeFractionableOptionsExpanded: Bool = false
    
    init(subscriptionEntity: CardSubscriptionEntityRepresentable, logoColor: UIColor, card: CardEntity?, merchantImageUrl: String?, baseUrl: String?, comesFromViewType: ShowCardSubscriprionFromView, isM4MactiveSuscriptionEnabled: Bool) {
        self.cardSubscriptionEntity = subscriptionEntity
        self.cardEntity = card
        self.logoColor = logoColor
        self.baseUrl = baseUrl
        self.corpImageURL = merchantImageUrl
        self.cardImageUrl = (baseUrl ?? "") + (card?.cardImageUrl() ?? "")
        self.isSubscriptionPaymentEnabled = isActiveSwitch ?? subscriptionEntity.active
        self.transactionViewModel = nil
        self.fromViewType = comesFromViewType
        self.isM4MactiveSuscriptionEnabled = isM4MactiveSuscriptionEnabled
    }
}
