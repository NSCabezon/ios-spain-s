import CoreDomain

extension SofiaInvestmentOptionType: AccessibilityProtocol {
   public var accessibilityIdentifier: String? {
        switch self {
        case .managedPortfolios:
            return AccessibilitySideInvestment.btnMyInvestiment
        case .notManagedPortfolios:
            return AccessibilitySideInvestment.btnDiscretionaryManagement
        case .variableIncome:
            return AccessibilitySideInvestment.btnVariableIncome
        case .ordersSigning:
            return AccessibilitySideInvestment.btnOrdersSigning
        case .unadvisedOrders:
            return AccessibilitySideInvestment.btnUnadvisedOrders
        case .sofiaOperate:
            return AccessibilitySideInvestment.btnOperate
        case .sofiaOrder:
            return AccessibilitySideInvestment.btnOrders
        case .sofiaMovement:
            return AccessibilitySideInvestment.btnMoves
        case .sofiaProposition:
            return AccessibilitySideInvestment.btnRecommendation
        case .sofiaMarket:
            return AccessibilitySideInvestment.btnMarket
        case .sofiaFavourite:
            return AccessibilitySideInvestment.btnFavorite
        case .sofiaAnalysis:
            return AccessibilitySideInvestment.btnAnalysis
        case .smartTrader:
            return AccessibilitySideInvestment.btnSmartTrader
        case .sofiaGuidance:
            return AccessibilitySideInvestment.btnSanOrient
        case .shareholders:
            return AccessibilitySideInvestment.btnStockholders
        case .invest:
            return AccessibilitySideInvestment.btnInvestments
        case .testMifid:
            return AccessibilitySideInvestment.btnTest
        case .ebroker:
            return AccessibilitySideInvestment.btnEbroker
        case .mifid:
            return AccessibilitySideInvestment.btnTest
        case .foreignExchange:
            return AccessibilitySideInvestment.btnForeignExchange
        case .pensions:
            return AccessibilitySideInvestment.btnPensions
        case .roboadvisor:
            return AccessibilitySideInvestment.btnRoboadvisor
        case .investmentAlerts:
            return AccessibilitySideInvestment.btnInvestmentAlert
        case .funds:
            return AccessibilitySideInvestment.btnFunds
        case .guaranteed:
            return AccessibilitySideInvestment.btnGuaranteed
        case .investmentPosition:
            return AccessibilitySideInvestment.btnPosition
        case .stocks:
            return AccessibilitySideInvestment.stocks
        case .newTestMifid:
            return AccessibilitySideInvestment.newTestMifid
        case .fixedRent:
            return AccessibilitySideInvestment.fixedRent
        case .titleWantInvest:
            return AccessibilitySideInvestment.titleWantInvest
        case .titleTools:
            return AccessibilitySideInvestment.titleTools
        }
    }
}
