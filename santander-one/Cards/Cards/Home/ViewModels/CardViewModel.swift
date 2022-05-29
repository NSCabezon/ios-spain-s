//
//  CardViewModel.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/29/19.
//

import Foundation
import CoreFoundationLib
import UI

public enum CardApplePayState {
    case notSupported
    case inactive
    case inactiveAndDisabled
    case active
}

public final class CardViewModel {
    let entity: CardEntity
    var baseUrl: String?
    var monthExpensesEntity: AmountEntity?
    var applePayState: CardApplePayState
    let isMapEnable: Bool
    var isPaymentMethodSuccess: Bool
    var paymentMethodDescription: LocalizedStylableText?
    var cardActionViewModel: CardActionViewModel?
    var dependenciesResolver: DependenciesResolver
    let isEnableCashWithDrawal: Bool
    let settlementDetailEntity: CardSettlementDetailEntity?
    let scaDate: Date?
    let showLoading: Bool
    let maskedPAN: Bool
    let hideDetailsHomeCardConditions: Bool
    
    public init(_ entity: CardEntity,
                baseUrl: String? = nil,
                applePayState: CardApplePayState,
                isMapEnable: Bool,
                isEnableCashWithDrawal: Bool,
                dependenciesResolver: DependenciesResolver,
                isPaymentMethodSuccess: Bool = false,
                paymentMethodDescription: LocalizedStylableText? = nil,
                settlementDetailEntity: CardSettlementDetailEntity? = nil,
                scaDate: Date? = nil,
                showLoading: Bool = true,
                maskedPAN: Bool,
                hideCardsImageDetails: Bool = false) {
        self.entity = entity
        self.baseUrl = baseUrl
        self.applePayState = applePayState
        self.isMapEnable = isMapEnable
        self.isEnableCashWithDrawal = isEnableCashWithDrawal
        self.dependenciesResolver = dependenciesResolver
        self.isPaymentMethodSuccess = isPaymentMethodSuccess
        self.paymentMethodDescription = paymentMethodDescription
        self.settlementDetailEntity = settlementDetailEntity
        self.scaDate = scaDate
        self.showLoading = showLoading
        self.maskedPAN = maskedPAN
        self.hideDetailsHomeCardConditions = hideCardsImageDetails
    }
    
    var amount: String? {
        return entity.amountUI
    }
    
    var isCreditCard: Bool {
        return entity.isCreditCard
    }
    
    var isPrepaidCard: Bool {
        return entity.isPrepaidCard
    }
    
    var isDebitCard: Bool {
        return entity.isDebitCard
    }
    
    public var isDisabled: Bool {
        return entity.isDisabled
    }
    
    public var isInactive: Bool {
        return entity.isInactive
    }
    
    public var cardImageFallback: UIImage? {
        let cardDefaultFallbackModifier = self.dependenciesResolver.resolve(forOptionalType: CardDefaultFallbackImageModifierProtocol.self)
        guard let image = cardDefaultFallbackModifier?.defaultFallbackImage(card: cardEntity) else {
            return Assets.image(named: "defaultEnabledCard")
        }
        return image
    }
    
    var collapsedBalanceAmount: String? {
        if isCreditCard {
            return entity.currentBalance.getAbsFormattedAmountUI()
        } else if isPrepaidCard {
            return entity.availableAmount.getFormattedAmountUI()
        } else {
            return nil
        }
    }
    
    var balanceAmountAttributedString: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32)
        let amount = MoneyDecorator(entity.currentBalance, font: font)
        return amount.getFormatedAbsWith1M()
    }
    
    var availableAmountLocalizedText: LocalizedStylableText {
        let font: UIFont = UIFont.santander(family: .text, type: .regular, size: 13)
        let amount = MoneyDecorator(entity.availableAmount, font: font)
        guard let stringAmount = amount.getCurrencyWithoutFormat()?.string else { return .empty }
        return localized("cardsHome_label_available", [StringPlaceholder(.value, stringAmount)])
    }
    
    var availableAmountAttributedString: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32)
        let amount = MoneyDecorator(entity.availableAmount, font: font)
        return amount.getFormatedCurrency()
    }
    
    var monthExpensesLocalizedText: LocalizedStylableText? {
        guard let expenses = self.monthExpensesEntity else { return nil }
        return localized("card_label_spentMonthValue",
                         [(StringPlaceholder(.value, expenses.getStringValue()))])
    }
    
    var monthExpensesAttriburtedString: NSAttributedString? {
        guard let expensesAmount: AmountEntity = self.monthExpensesEntity else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32)
        let amount = MoneyDecorator(expensesAmount, font: font)
        return amount.getFormatedCurrency()
    }
    
    var creditLimitsAmountLocalizedText: LocalizedStylableText {
        let font = UIFont.santander(family: .text, type: .regular, size: 13)
        let amount = MoneyDecorator(entity.creditLimitAmount, font: font)
        guard let stringAmount = amount.getCurrencyWithoutFormat()?.string else { return .empty}
        return localized("cardsHome_label_limit", [StringPlaceholder(.value, stringAmount)])
    }
    
    var creditExpenses: Float {
        guard let balance = entity.currentBalance.value else { return 0 }
        guard let creditLimits = entity.creditLimitAmount.value else { return 0 }
        let decimalNumber = NSDecimalNumber(decimal: balance * 100 / creditLimits)
        guard !decimalNumber.floatValue.isNaN else { return 0 }
        return abs(decimalNumber.floatValue)
    }
    
    var atmDailyLimitAmountLocalizedText: LocalizedStylableText {
        if let deilyATMLimit = entity.dailyATMLimit {
            return localized("cardHome_label_atmLimit",
                             [StringPlaceholder(.number, deilyATMLimit.getStringValue(withDecimal: 0))])
        } else {
            return LocalizedStylableText(text: "", styles: nil)
        }
    }
    
    var shopLimitAmountLocalizedText: LocalizedStylableText {
        if let dailyLimit = entity.dailyLimit {
            return localized("cardHome_label_limitsCommerces",
                             [StringPlaceholder(.number, dailyLimit.getStringValue(withDecimal: 0))])
        } else {
            return LocalizedStylableText(text: "", styles: nil)
        }
    }
    
    var miniatureImageUrl: String? {
        guard let baseUrl = baseUrl else { return nil }
        return baseUrl + entity.buildImageRelativeUrl(miniature: true)
    }
    
    func setCardActionViewModel(_ viewModel: CardActionViewModel?) {
        self.cardActionViewModel = viewModel
    }
    
    var trackId: String {
        return entity.trackId
    }
    
    var ascriptionDate: String? {
        let timeManager: TimeManager = dependenciesResolver.resolve()
        return timeManager.toString(date: settlementDetailEntity?.ascriptionDate, outputFormat: .d_MMM)?.uppercased()
    }
    
    var settlementeFromDateToDate: LocalizedStylableText? {
        let timeManager: TimeManager = dependenciesResolver.resolve()
        guard let settlementDetailEntity = settlementDetailEntity,
              settlementDetailEntity.startDate != nil,
              let endDate = settlementDetailEntity.endDate,
              let ascriptionDate = settlementDetailEntity.ascriptionDate,
              let startDateString = timeManager.toString(date: settlementDetailEntity.startDate, outputFormat: .dd_7_MM),
              let endDateString = timeManager.toString(date: settlementDetailEntity.endDate, outputFormat: .dd_7_MM) else {
                  return nil
              }
        let scaDate = self.scaDate ?? Date()
        guard endDate.addDay(days: 1) <= ascriptionDate &&
                (endDate.addDay(days: 1) ... ascriptionDate).contains(scaDate) else {
                    return localized("nextSettlement_label_datesPeriod", [StringPlaceholder(.date, startDateString), StringPlaceholder(.date, endDateString)])
                }
        settlementInTime = true
        return localized("nextSettlement_label_viewAndDeferBill")
    }
    
    var settlementAmount: NSAttributedString? {
        guard let totalAmount = settlementDetailEntity?.totalAmount else { return nil }
        let font: UIFont = .santander(family: .text, type: .bold, size: 16)
        let amount = MoneyDecorator(totalAmount, font: font, decimalFontSize: 14)
        return amount.formatAsMillions()
    }
    
    var settlementInTime: Bool = false
    
    var shareImageViewNewSize: CGFloat {
        maskedPAN ? 24.0 : 16.0
    }
    
    var shareImageView: String {
        if maskedPAN {
            return "icnVisible"
        } else {
            return "icnGrayShare"
        }
    }
    
    var maskedPANLabel: String {
        guard let lastPanDigits = self.pan?.substring(ofLast: 4) else { return "" }
        let circles = "\u{25CF}\u{25CF}\u{25CF}\u{25CF} \u{25CF}\u{25CF}\u{25CF}\u{25CF} \u{25CF}\u{25CF}\u{25CF}\u{25CF} "
        return circles + lastPanDigits
    }
    
    var showActivateView: Bool {
        guard let cardHomeModifier = self.dependenciesResolver.resolve(forOptionalType: CardHomeModifierProtocol.self) else { return false }
        return cardHomeModifier.showActivateView()
    }
}

extension CardViewModel: Equatable {
    
    public static func == (lhs: CardViewModel, rhs: CardViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension CardViewModel: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pan)
    }
}

extension CardViewModel: Shareable {
    public func getShareableInfo() -> String {
        return entity.detailUI ?? ""
    }
}

extension CardViewModel: CardViewModelInfoRepresentable {
    public var cardEntity: CardEntity {
        self.entity
    }
    
    public var cardTextColorEntity: [CardTextColorEntity] {
        self.dependenciesResolver.resolve(for: [CardTextColorEntity].self)
    }
    
    public var fullCardImageStringUrl: String? {
        guard let baseUrl = baseUrl else { return nil }
        return baseUrl + entity.buildImageRelativeUrl(miniature: false)
    }
    
    public var pan: String? {
        guard let plasticCardModifier = self.dependenciesResolver.resolve(forOptionalType: CardHomeModifierProtocol.self) else { return self.entity.detailUI }
        return plasticCardModifier.formatPAN(card: self.entity)
    }
}
