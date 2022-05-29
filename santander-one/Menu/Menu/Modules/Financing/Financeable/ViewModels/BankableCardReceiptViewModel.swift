//
//  BankableCardReceiptViewModel.swift
//  Menu
//
//  Created by Sergio Escalante Ordoñez on 13/1/22.
//

import CoreFoundationLib

enum BankableCardReceiptType {
    case receipt
}

struct BankableCardReceiptViewModel {
    private(set) var cardDetailSettlement: CardSettlementDetailEntity?
    private(set) var cardEntity: CardEntity?
    private var baseUrl: String?
    private let timeManager: TimeManager

    init(cardDetailSettlement: CardSettlementDetailEntity? = nil,
         cardEntity: CardEntity? = nil,
         baseUrl: String?,
         timeManager: TimeManager) {
        self.cardDetailSettlement = cardDetailSettlement
        self.cardEntity = cardEntity
        self.baseUrl = baseUrl
        self.timeManager = timeManager
    }
    
    var operativeDate: Date {
         cardDetailSettlement?.ascriptionDate ?? Date()
    }

    var amount: String? {
        cardDetailSettlement?.totalAmount.getStringValue()
    }

    var dateFormatted: String {
        timeManager.toStringFromCurrentLocale(date: operativeDate, outputFormat: .d_MMM)?.uppercased() ?? ""
    }

    var cardDescription: String? {
        return cardEntity?.getAliasAndInfo()
    }

    var miniatureImageUrl: String? {
        guard let baseUrl = baseUrl, let cardEntity = self.cardEntity else { return nil }
        return baseUrl + cardEntity.buildImageRelativeUrl(miniature: true)
    }
}
