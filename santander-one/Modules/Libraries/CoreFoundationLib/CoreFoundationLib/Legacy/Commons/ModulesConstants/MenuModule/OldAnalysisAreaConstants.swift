
public struct OldAnalysisAreaPullOffers {
    public static let analysisMoneyPlan = "ANALYSIS_MONEYPLAN"
    public static let analysisCustomTip = "ANALYSIS_CUSTOM_TIPS"
    public static let analysisPiggyBank = "ANALYSIS_ZONE_HUCHA"
}

public struct OldAnalysisAreaPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/analysis"
    
    public enum Action: String {
        case expand = "expand_information"
        case create = "add_budget"
        case edit = "edit_budget"
        case swipe = "swipe_moneysaving_tip"
        case financialCushion = "click_financial_cushion"
        case clickHelpBudget = "click_help_budget"
    }
    public init() {}
}

public struct OldAnalysisAreaBudgetPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/global_position/cost_analysis"
    
    public enum Action: String {
        case save = "save_change"
    }
    public init() {}
}

public struct OldAnalysisAreaBalancePage: PageTrackable {
    public let page = "analisis_balance"
    public init() {}
}

public struct OldAnalysisAreaTransfersPage: PageTrackable {
    public let page = "analisis_transferencias"
    public init() {}
}

public struct OldAnalysisAreaBizumPage: PageTrackable {
    public let page = "analisis_bizum"
    public init() {}
}

public struct OldAnalysisAreaSubscriptionsPage: PageTrackable {
    public let page = "analisis_suscripciones"
    public init() {}
}

public struct OldAnalysisAreaReceiptsPage: PageTrackable {
    public let page = "analisis_recibos"
    public init() {}
}

public struct OldAnalysisAreaDebtsPage: PageTrackable {
    public let page = "analisis_deuda"
    public init() {}
}
