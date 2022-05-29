//
//  FinancingPage.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 7/8/20.
//
import Foundation

public struct FinancingConstants {
    public static let adobeTargetOfferEnabled = "enableAdobeTarget"
    public static let needMoney = "ZF_NECESITO_DINERO"
    public static let bigOffer = "ZF_HOME"
    public static let secondBigOffer = "ZF_BIG_OFFER_2"
    public static let carousel = "ZF_CONTRATAR_TARJETAS"
    public static let easyPayHighAmount = "ZF_EASY_PAY_HIGH_AMOUNT"
    public static let easyPayLowAmount = "ZF_EASY_PAY_LOW_AMOUNT"
    public static let robinson = "PRE_CONCEDIDOS_ROBINSON_BIG"
    public static let defaultersWeb = "ZF_DEFAULTER_WEB"
    public static let commercialOffer1 = "FINANCING_COMMERCIAL_OFFERS1"
    public static let commercialOffer2 = "FINANCING_COMMERCIAL_OFFERS2"
    public static let webViewUrl = "financingUrl"
    public static let closeUrl = "financingCloseUrl"
}

public struct FinancingPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/financing/to_finance"
    public enum Action: String {
        case seeAllAccounts = "see_all_accounts"
        case seeAllCards = "see_all_cards"
        case cardDetail = "click_fractionables_card_detail"
        case accountDetail = "click_fractionables_account_detail"
        case viewPromotion = "view_promotion"
        case selectContent = "select_content"
        case promoView = "promo_view"
        case promoClick = "promo_click"
        case fractionateCreditCardPayments = "view_instalment_payments_credit_card"
        case fractionateBills = "view_instalment_bills"
        case fractionateTransfers = "view_instalment_transfers"
        case fractionatePurchases = "view_instalment_purchase"
        case financeCardReceipt = "finance_card_receipt"
    }
    public init() {}
}

public struct FractionedPaymentsPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/financing/to_finance/option_list"
    public enum Action: String {
        case clickDetail = "click_detail"
        case unfoldOptions = "unfold_options"
        case unfoldOptionsEasyPay = "unfold_options_easyPay"
        case seeMoreCards = "view_more_cards"
    }
    public init() {}
}

public struct FinancingUpdatePage: PageTrackable {
    public let page = "/financing/update"
    public init() {}
}

public struct FinancingDistributionPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/financing/your_financing"
    public enum Action: String {
            case clickDetail = "click_fractionated_detail"
            case viewMorePayments = "view_more_installment_payments"
            case swipeCarousel = "swipe_carousel"
        }
    public init() {}
}

public struct AccountFinanceableDistributionPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/financing/to_finance/account_month_detail"
    public enum Action: String {
        case fractionablesAccountMonthDetail = "click_fractionables_account_month_detail"
    }
    public init() {}
}

public struct CardFinancebleTransactionpage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/financing/to_finance/card_month_detail"
    public enum Action: String {
        case fractionablesCardMonthDetail = "click_fractionables_card_month_detail"
        case clickDropdownOptions = "click_fractionables_card_month_detail_dropdown_options"
        case clickFractionableOption = "click_fractionables_card_month_detail_click_option"
    }
    public init() {}
}
