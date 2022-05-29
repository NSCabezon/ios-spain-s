//
//  FundsConstants.swift
//  CoreFoundationLib
//
//  Created by Simón Aparicio on 21/4/22.
//

public struct FundPage: PageWithActionTrackable {
    public typealias ActionType = Action

    public let page = "/fund"

    public enum Action: String {
        case select = "select_content"
        case share = "share_fund_account_carrousel"
        case profitabilityTooltip = "tap_tooltip_profitability"
        case operate = "click_operate"
        case browser = "click_fund_browser"
        case unfoldDetails = "unfold_fund_detail"
        case foldDetails = "fold_fund_detail"
        case unfoldOrdersAndTransactions = "unfold_order_transaction"
        case foldOrdersAndTransactions = "fold_order_transaction"
        case units = "click_order_transaction_detail"
        case more = "click_view_more"
        case menu = "click_private_menu"
        case back = "click_back"
        case shareAssociatedAccount = "share_fund_account_detail"
        case shareTransaction = "share_fund_transaction"
        case error // TODO: api or system error occurs
    }
    public init() {}
}

public struct FundProfitabilityPage: PageWithActionTrackable {
    public typealias ActionType = Action

    public let page = "/fund/profitability"

    public enum Action: String {
        case close = "click_close"
    }
    public init() {}
}

public struct FundTransactionsPage: PageWithActionTrackable {
    public typealias ActionType = Action

    public let page = "/fund/order_transaction"

    public enum Action: String {
        case filter = "click_filter"
        case units = "click_order_transaction_detail"
        case share = "share_fund_transaction"
        case menu = "click_private_menu"
        case back = "click_back"
        case clear = "clear_filter"
        case clearAll = "clear_all_filters"
        case error
    }
    public init() {}
}

public struct FundTransactionsFilterPage: PageWithActionTrackable {
    public typealias ActionType = Action

    public let page = "/fund/order_transaction/filter"

    public enum Action: String {
        case apply = "click_apply"
        case back = "click_back"
        case close = "click_close"
    }
    public init() {}
}
