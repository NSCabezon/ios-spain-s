//
//  SavingProductsConstants.swift
//  CoreFoundationLib
//
//  Created by Serrano gomez, Antonio on 11/03/2022.
//

public struct SavingProductsHome: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/saving"
    public enum Action: String {
        case swipe = "swipe_saving_carrousel"
        case shareIban = "share_iban"
        case tapTooltipSaving = "tap_tooltip_saving"
        case tapTooltipBalance = "tap_tooltip_balance"
        case viewDetail = "view_detail"
        case clickSendMoney = "click_send_money"
        case clickStatements = "click_statements"
        case clickRegularPayments = "click_regular_payments"
        case clickViewCards = "click_view_cards"
        case clickApply = "click_apply"
        case error = "error"
        case viewInterestRateDetail = "view_interest_rate_detail"
        case viewTransactionPdf = "view_transaction_pdf"
        case clickFrecuentShortcut = "click_frecuent_shortcut"
        case clickMoreOption = "click_more_option"
    }
    public init() {}
}

public struct SavingDetailPage: PageWithActionTrackable {
    public typealias ActionType = Action

    public let page = "/saving/detail"
    public let balancePage = "/saving/detail/balance"
    public let interestRatePage = "/saving/detail/interest_rate"

    public enum Action: String {
        case copySavingProductNumber = "copy_saving_product_number"
        case tapTooltipBalance = "tap_tooltip_balance"
        case tapTooltipInterestRate = "tap_tooltip_interest_rate"
        case shareAccountNumber = "share_account_number"
        case changeAlias = "change_alias"
        case clickCancel = "click_cancel"
    }
    public init() {}
}

public struct SavingMoreOptionsPage: PageWithActionTrackable {
    public typealias ActionType = Action

    public let page = "/saving/more_option"

    public enum Action: String {
        case selectContent = "select_content"
        case clickCancel = "click_cancel"
    }
    public init() {}
}
