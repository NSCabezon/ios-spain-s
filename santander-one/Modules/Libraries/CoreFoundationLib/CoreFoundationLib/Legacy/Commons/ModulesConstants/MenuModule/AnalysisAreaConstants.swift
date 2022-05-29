//
//  AnalysisAreaConstants.swift
//  Commons
//
//  Created by Miguel Ferrer Fornali on 20/1/22.
//

public struct AnalysisAreaFinancialHealthPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/financial_health"
    
    public enum Action: String {
        case clickSaving = "click_saving"
        case clickExpenseAnalysis = "click_expense_analysis"
        case clickChangeView = "click_change_view"
        case clickExpenseView = "click_expense_view"
        case clickIncomeView = "click_income_view"
        case clickPrivateMenu = "click_private_menu"
        case clickBack = "click_back"
        case clickConfiguration = "click_configuration"
        case clickAddBank = "click_add_bank"
        case selectContent = "select_content"
    }
    public init() {}
}

public struct AnalysisAreaErrorPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/financial_health/error"
    
    public enum Action {
        case error
    }
    public init() {}
}

public struct AnalysisAreaInfoPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/financial_health/info"
    
    public enum Action {
        case info
    }
    public init() {}
}

public struct AnalysisAreaFinancialHealthFilterPage: PageTrackable {
    public let page = "/financial_health/filter"
    public init() {}
}

public struct AnalysisAreaFinancialHealthOtpPage: PageTrackable {
    public let page = "/financial_health/otp"
    public init() {}
}

public struct AnalysisAreaTmaPinPage: PageTrackable {
    public let page = "/tma/pin"
    public init() {}
}

public struct AnalysisAreaTmaPinIvrPage: PageTrackable {
    public let page = "/tma/pin/ivr"
    public init() {}
}

public struct AnalysisAreaTmaPinIvrOtpPage: PageTrackable {
    public let page = "/tma/pin/ivr/otp"
    public init() {}
}

public struct AnalysisAreaTmaPinIvrHwTokenPage: PageTrackable {
    public let page = "/tma/pin/ivr/hw_token"
    public init() {}
}

public struct AnalysisAreaConstants {
    public static let addOtherBanks = "FINANCIALHEALTH_ADDOTHERSBANKS"
    public static let manageOtherBanks = "FINANCIALHEALTH_MANAGEOTHERSBANKS"
}

public var analysisArea: [PullOfferLocation] {
    return
    [PullOfferLocation(stringTag: AnalysisAreaConstants.addOtherBanks, hasBanner: false, pageForMetrics: ""),
    PullOfferLocation(stringTag: AnalysisAreaConstants.manageOtherBanks, hasBanner: false, pageForMetrics: "")]
}
