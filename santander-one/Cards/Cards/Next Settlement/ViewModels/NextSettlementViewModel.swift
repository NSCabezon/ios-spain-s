//
//  NextSettlementViewModel.swift
//  Cards
//
//  Created by Laura González on 13/10/2020.
//

import Foundation
import CoreFoundationLib
import UI

enum NumberOfCards {
    case one
    case two
    case more
}

final class NextSettlementViewModel: NSCopying {
    private var configuration: NextSettlementConfiguration
    private var cardDetail: CardDetailEntity?
    private var baseUrl: String?
    var movements: [NextSettlementMovementWithPANViewModel]?
    private var paymentMethod: CardPaymentMethodTypeEntity?
    private var paymentMethodDescription: String?
    private let isMultipleMapEnabled: Bool
    private var currentPanSelected: String
    private let ownerPan: String
    private let scaDate: Date
    private let enablePayLater: Bool
    
    public init(_ configuration: NextSettlementConfiguration, cardDetail: CardDetailEntity?, baseUrl: String?, movements: [NextSettlementMovementWithPANViewModel]?, paymentMethod: CardPaymentMethodTypeEntity?, paymentMethodDescription: String?, isMultipleMapEnabled: Bool, ownerPan: String, scaDate: Date, enablePayLater: Bool) {
        self.configuration = configuration
        self.cardDetail = cardDetail
        self.baseUrl = baseUrl
        self.movements = movements
        self.paymentMethod = paymentMethod
        self.paymentMethodDescription = paymentMethodDescription
        self.isMultipleMapEnabled = isMultipleMapEnabled
        self.currentPanSelected = configuration.card.pan
        self.ownerPan = ownerPan
        self.scaDate = scaDate
        self.enablePayLater = enablePayLater
    }
    
    var cardEntity: CardEntity {
        return self.configuration.card
    }
    
    var settlementDetailEntity: CardSettlementDetailEntity {
        return self.configuration.cardSettlementDetailEntity
    }
        
    var startDate: String? {
        return dateToString(date: settlementDetailEntity.startDate, outputFormat: .d_MMM)
    }
    
    var endDate: String? {
        return dateToString(date: settlementDetailEntity.endDate, outputFormat: .d_MMM)
    }
    
    var datesText: LocalizedStylableText {
        guard let endDate = endDate, let startDate = startDate else { return .empty }
        return localized("nextSettlement_label_ofThe", [StringPlaceholder(.date, startDate.uppercased()), StringPlaceholder(.date, endDate.uppercased())])
    }
    
    var totalAmount: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 36.0)
        if settlementDetailEntity.emptyMovements {
            let zeroAmount = AmountEntity(value: 0.0)
            let amount = MoneyDecorator(zeroAmount, font: font, decimalFontSize: 20.0)
            return amount.getFormatedCurrency()
        } else {
            let amount = MoneyDecorator(settlementDetailEntity.totalAmount, font: font, decimalFontSize: 20.0)
            return amount.getFormatedCurrency()
        }
    }
    
    var cardName: String {
        return cardEntity.alias ?? ""
    }
    
    var imageUrl: String {
        guard let url = baseUrl else { return "" }
        return url + cardEntity.buildImageRelativeUrl(miniature: true)
    }
    
    var associatedImageUrl: [String]? {
        guard baseUrl != nil, let cards = self.movements else { return nil }
        var imageUrls: [String] = []
        for card in cards where !card.isTitular {
            imageUrls.append(card.cardEntity.cardImageUrl())
        }
        return imageUrls
    }
    
    var chargeDateText: LocalizedStylableText {
        guard let date = dateToString(date: settlementDetailEntity.ascriptionDate, outputFormat: .dd_MM_yy) else {
            return localized("nextSettlement_label_notPendingSettlement")
        }
        guard let cardDetail = cardDetail else {
            return localized("nextSettlement_label_chargeDay", [StringPlaceholder(.date, date)])
        }
        let text = localized("nextSettlement_label_chargeYourAccount", [StringPlaceholder(.value, cardDetail.linkedAccountShort), StringPlaceholder(.date, date)])
        return text
    }
    
    var operationType: PaymentTypeViewModel? {
        guard let paymentMethod = paymentMethod, let paymentMethodDescription = paymentMethodDescription else { return nil }
        return PaymentTypeViewModel(paymentMethod, paymentMethodDescription: paymentMethodDescription)
    }
    
    var contract: String {
        return cardEntity.formattedContract
    }
    
    var getMultipleMapEnabled: Bool {
        return self.isMultipleMapEnabled
    }
    
    var isEnabledPostponeReceipt: Bool {
        return getEnabledPostponeReceipt(self.cardEntity)
    }
    
    var isReceiptRemarkable: Bool {
        return self.isEnabledPostponeReceipt ? self.evaluatePostponeReceiptIsOnDate() : false
    }
    
    func evaluatePostponeReceiptIsOnDate() -> Bool {
        guard let endDate = self.settlementDetailEntity.endDate?.addDay(days: 1),
            let ascriptionDate = self.settlementDetailEntity.ascriptionDate,
            endDate < scaDate,
            scaDate < ascriptionDate else {
                return false
        }
        return true
    }
    
    var getCurrentPanSelected: String {
        return self.currentPanSelected
    }
    
    var getOriginalCardIsOwner: Bool {
        guard !getOwnerPan.isEmpty else {
            return true
        }
        return getOriginalPan == getOwnerPan
    }
    
    var getOriginalCardIsSelected: Bool {
        return getOriginalPan == getCurrentPanSelected
    }
    
    var getMovementWithPan: NextSettlementMovementWithPANViewModel? {
        let movements = self.movements?.first(where: { $0.cardEntity.pan == getCurrentPanSelected})
        return movements
    }
    
    var getOwnerPan: String {
        return ownerPan
    }
    
    var getOwnerPanOrOriginalPan: String {
        guard !getOwnerPan.isEmpty else {
            return getOriginalPan
        }
        return ownerPan
    }
    
    var getFirstAssociatedPan: String {
        return getMovementsPans.first(where: { $0 != getOwnerPanOrOriginalPan }) ?? ""
    }
    
    func setCurrentPanSelected(_ currentPanSelected: String) {
        self.currentPanSelected = currentPanSelected
    }
    
    var ownerCards: [OwnerCards]? {
        guard let number = self.movements?.count, number > 0 else { return nil }
        let ownerCards: [OwnerCards] = (0...number - 1).compactMap { (index) in
            let stringPlaceholder = [StringPlaceholder(.number, "\(index + 1)"), StringPlaceholder(.number, number.description)]
            let number = localized("nextSettlement_label_titularCardPosition", stringPlaceholder)
            let cardName = self.movements?[index].cardEntity.alias ?? ""
            let pan = self.movements?[index].cardEntity.formattedPAN ?? ""
            let entity = self.movements?[index].cardEntity
            return OwnerCards(entity, urlString: self.imageUrl, text: cardName, number: number, pan: pan, position: index)
        }
        return ownerCards
    }
    
    func getCurrentCardSelected(_ pan: String) -> OwnerCards? {
        return ownerCards?.first(where: { $0.pan == pan })
    }
    
    func getOrderButtons() -> (principal: String, secondary: String) {
        guard ownerPan.isEmpty else {
            return (ownerPan, getFirstAssociatedPan)
        }
        return (cardEntity.pan, getFirstAssociatedPan)
    }
    
    func isOrderButtonsReversed() -> Bool {
        guard !ownerPan.isEmpty else {
            return false
        }
        return ownerPan != cardEntity.pan
    }
    
    var getScaDate: Date {
        return self.scaDate
    }
    
    func getNumberOfCards() -> NumberOfCards {
        guard let cards = self.movements?.count, cards > 0 else { return .one }
        switch cards {
        case 1:
            return .one
        case 2:
            return .two
        default:
            return .more
        }
    }
    
    func getEnabledPostponeReceipt(_ card: CardEntity) -> Bool {
        let minimumAmount: Decimal = 25.0
        guard let cardEntity = self.getCurrentCardSelected(card.pan)?.entity,
            cardEntity.isOwnerSuperSpeed,
            cardEntity.isContractActive,
            cardEntity.isCardContractHolder,
            abs(cardEntity.currentBalance.value ?? 0.0) > 0.0,
            settlementDetailEntity.totalAmount.value ?? 0.0 >= minimumAmount,
            settlementDetailEntity.extractNumber != nil else {
                return false
        }
        return enablePayLater
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = NextSettlementViewModel(configuration, cardDetail: cardDetail, baseUrl: baseUrl, movements: movements, paymentMethod: paymentMethod, paymentMethodDescription: paymentMethodDescription, isMultipleMapEnabled: isMultipleMapEnabled, ownerPan: ownerPan, scaDate: scaDate, enablePayLater: enablePayLater)
        copy.currentPanSelected = currentPanSelected
        return copy
    }
}

private extension NextSettlementViewModel {
    var getMovementsPans: [String] {
        guard let movementPans: [String] = self.movements?.compactMap({ $0.cardEntity.pan }) else {
            return []
        }
        return movementPans
    }
    
    var getOriginalPan: String {
        return self.cardEntity.pan
    }
}
