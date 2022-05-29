public enum SofiaInvestmentOptionType {
    case managedPortfolios
    case notManagedPortfolios
    case variableIncome
    case ordersSigning
    case unadvisedOrders
    case sofiaOperate
    case sofiaOrder
    case sofiaMovement
    case sofiaProposition
    case sofiaMarket
    case sofiaFavourite
    case sofiaAnalysis
    case smartTrader
    case sofiaGuidance
    case shareholders
    case invest
    case testMifid
    case mifid
    case ebroker
    case foreignExchange
    case pensions
    case roboadvisor
    case investmentAlerts
    case funds
    case guaranteed
    case investmentPosition
    case stocks
    case newTestMifid
    case fixedRent
    case titleWantInvest
    case titleTools
}

public extension SofiaInvestmentOptionType {
    var titleKey: String {
        switch self {
        case .managedPortfolios:
            return "menuMyInvestiment_link_portfolioManaged"
        case .notManagedPortfolios:
            return "menuMyInvestiment_link_portfolioNotManaged"
        case .variableIncome:
            return "menuMyInvestiment_link_variableIncome"
        case .ordersSigning:
            return "menu_link_ordersSigning"
        case .unadvisedOrders:
            return "menu_link_unadvisedOrders"
        case .sofiaOperate:
            return "menuSofia_link_operate"
        case .sofiaOrder:
            return "menuSofia_link_orders"
        case .sofiaMovement:
            return "menuSofia_link_moves"
        case .sofiaProposition:
            return "menuSofia_link_motionRecommendation"
        case .sofiaMarket:
            return "menuSofia_link_market"
        case .sofiaFavourite:
            return "menuSofia_link_favorite"
        case .sofiaAnalysis:
            return "menuSofia_link_analysis"
        case .smartTrader:
            return "menuSofia_link_SmartTrader"
        case .sofiaGuidance:
            return "menuSofia_link_sanOrient"
        case .shareholders:
            return "menu_link_stockholders"
        case .invest:
            return "pt_menuInvestment_link_wantInvest"
        case .testMifid:
            return "pt_menuInvestment_link_mifidTest"
        case .ebroker:
            return "pt_menuInvestment_link_eBroker"
        case .mifid:
            return "pt_menuInvestment_link_mifidTest"
        case .foreignExchange:
            return "menuMyInvestiment_link_currency"
        case .pensions:
            return "menuMyProduct_link_plans"
        case .roboadvisor:
            return "menuMyInvestiment_link_roboadvisor"
        case .investmentAlerts:
            return "menuMyInvestiment_link_investmentAlerts"
        case .funds:
            return "menuMyProduct_link_funds"
        case .guaranteed:
            return "menuMyInvestiment_link_assure"
        case .investmentPosition:
            return "menuSofia_link_investmentPlatform"
        case .stocks:
            return "menuMyInvestiment_link_stocks"
        case .newTestMifid:
            return "menuMyInvestiment_link_testMifid"
        case .fixedRent:
            return "menuMyInvestiment_link_fixedRetn"
        case .titleWantInvest:
            return "menuInvestment_title_wantInvest"
        case .titleTools:
            return "menu_title_tools"
        }
    }
    
    var icon: String {
        switch self {
        case .managedPortfolios:
            return "icnManagedWalletRed"
        case .notManagedPortfolios:
            return "icnUnmanagedWalletRed"
        case .variableIncome:
            return "icnVariableIncomeMenu"
        case .ordersSigning:
            return "icnSignatureOrders"
        case .unadvisedOrders:
            return "icnUnadvisedOrders"
        case .sofiaOperate:
            return "icnOperateMenu"
        case .sofiaOrder:
            return "icnOrders"
        case .sofiaMarket:
            return "icnMarketsRed"
        case .sofiaMovement:
            return "icnMovements"
        case .sofiaProposition:
            return "icnMotionRecommendation"
        case .sofiaFavourite:
            return "icnFavoriteRed"
        case .sofiaAnalysis:
            return "icnAnalysisRed"
        case .smartTrader:
            return "icnSmartTrade"
        case .sofiaGuidance:
            return "icnSanOrientaRed"
        case .shareholders:
            return "icnShareHoldersRed"
        case .invest:
            return "icnInvestments"
        case .testMifid:
            return "icnTestMifid"
        case .ebroker:
            return "icnEquities"
        case .mifid:
            return "icnTestMifid"
        case .foreignExchange:
            return "icnCurrencyMenu"
        case .pensions:
            return "icnPlansMenuRed"
        case .roboadvisor:
            return "icnRoboadvisor"
        case .investmentAlerts:
            return "icnInvestmentAlerts"
        case .funds:
            return "icnFundsMenuRed"
        case .guaranteed:
            return "icnAssure"
        case .investmentPosition:
            return "icnInvestmentPlatformRed"
        case .stocks:
            return "icnUnmanagedWalletRed"
        case .newTestMifid:
            return "icnTestMifid"
        case .fixedRent:
            return "icnRent"
        case .titleWantInvest, .titleTools:
            return ""
        }
    }
}