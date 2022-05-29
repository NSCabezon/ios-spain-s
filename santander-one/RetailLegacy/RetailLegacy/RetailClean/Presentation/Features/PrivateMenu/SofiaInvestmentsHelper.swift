import CoreDomain
import CoreFoundationLib
import CoreDomain

final class SofiaInvestmentsOption: PrivateSubmenuOptionRepresentable {
	
    let isPb: Bool
    let type: SofiaInvestmentOptionType
    let isInnerTitle: Bool
    
    var titleKey: String {
        switch type {
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
    
    var icon: String? {
        switch type {
        case .managedPortfolios:
            return "icnManagedWallet"
        case .notManagedPortfolios:
            return "icnUnmanagedWallet"
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
            return "icnSofiaMarket"
        case .sofiaMovement:
            return "icnMovements"
        case .sofiaProposition:
            return "icnMotionRecommendation"
        case .sofiaFavourite:
            return "icnFavorite"
        case .sofiaAnalysis:
            return "icnTest"
        case .smartTrader:
            return "icnSmartTrade"
        case .sofiaGuidance:
            return "icnSanOrienta"
        case .shareholders:
            return "icnShareholdersMenu"
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
            return "icnPlansMenu"
        case .roboadvisor:
            return "icnRoboadvisor"
        case .investmentAlerts:
            return "icnInvestmentAlerts"
        case .funds:
            return "icnFundsMenu"
        case .guaranteed:
            return "icnAssure"
        case .investmentPosition:
            return "icnInvestmentPlatform"
        case .stocks:
            return "icnUnmanagedWallet"
        case .newTestMifid:
            return "icnTestMifid"
        case .fixedRent:
            return "icnRent"
        case .titleWantInvest, .titleTools:
            return nil
        }
    }
    
    init(isPb: Bool, type: SofiaInvestmentOptionType, isInnerTitle: Bool = false) {
        self.isPb = isPb
        self.type = type
        self.isInnerTitle = isInnerTitle
    }
}

extension SofiaInvestmentsOption: AccessibilityProtocol {
	var accessibilityIdentifier: String? {
        switch type {
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

final class SofiaInvestmentsHelper {
    private var completion: (([PrivateSubmenuOptionRepresentable]) -> Void)?
    private weak var presenter: PrivateSubmenuPresenter?
    private var navigator: PrivateHomeNavigator
    private weak var offerDelegate: PrivateSideMenuOfferDelegate?
    
    var privateMenuWrapper: PrivateMenuWrapper
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().sofiaInvestment
    }
    
    init(privateMenuWrapper: PrivateMenuWrapper, presenter: PrivateSubmenuPresenter, navigator: PrivateHomeNavigator, offerDelegate: PrivateSideMenuOfferDelegate) {
        self.privateMenuWrapper = privateMenuWrapper
        self.presenter = presenter
        self.navigator = navigator
        self.offerDelegate = offerDelegate
    }
    
    private func wrapperUpdated() {
        getCandidateOffers { [weak self] candidates in
            guard let self = self else { return }
            let isPb = self.privateMenuWrapper.isPb
            let options: [SofiaInvestmentsOption] = self.getOptions(candidates, isPb: isPb)
            self.completion?(options)
        }
    }

    private func getOptions(_ candidates: [PullOfferLocation : Offer], isPb: Bool) -> [SofiaInvestmentsOption] {
        var options: [SofiaInvestmentsOption] = []
        var wantInvestItems: [SofiaInvestmentsOption] = []
        var toolsItems: [SofiaInvestmentsOption] = []
        // Investment position
        if candidates[.SIDE_INVESTMENT_MENU_POSITION] != nil {
            options += [SofiaInvestmentsOption(isPb: isPb, type: .investmentPosition)]
        }
        if isPb {
            // Portfolios under custody
            if !self.privateMenuWrapper.isPortfolioNotManagedMenuEmpty() {
                options += [SofiaInvestmentsOption(isPb: isPb, type: .notManagedPortfolios)]
            }
            // Discretionary transaction
            if !self.privateMenuWrapper.isPortfolioManagedMenuEmpty() {
                options += [SofiaInvestmentsOption(isPb: isPb, type: .managedPortfolios)]
            }
            // Proposed investments
            if candidates[.FIRMA_ORDENES] != nil {
                options += [SofiaInvestmentsOption(isPb: isPb, type: .ordersSigning)]
            }
            // Non-advised orders
            if candidates[.ORDENES_NO_ASESORADAS] != nil {
                options += [SofiaInvestmentsOption(isPb: isPb, type: .unadvisedOrders)]
            }
        }
        // Equity orders
        if candidates[.SOFIA_ORDENES] != nil {
            options += [SofiaInvestmentsOption(isPb: isPb, type: .sofiaOrder)]
        }
        // I WANT TO INVEST SECTION
        // Share
        if candidates[.SIDE_INVESTMENT_MENU_STOCKS] != nil {
            wantInvestItems += [SofiaInvestmentsOption(isPb: isPb, type: .stocks)]
        }
        // Fixed Income
        if candidates[.SIDE_INVESTMENT_MENU_FIXED_RENT] != nil {
            wantInvestItems += [SofiaInvestmentsOption(isPb: isPb, type: .fixedRent)]
        }
        // Guaranteed Products
        if candidates[.SIDE_INVESTMENT_MENU_GUARANTEED] != nil {
            wantInvestItems += [SofiaInvestmentsOption(isPb: isPb, type: .guaranteed)]
        }
        // Currencies
        if candidates[.SIDE_INVESTMENT_MENU_FOREINGN_EXCHANGE] != nil {
            wantInvestItems += [SofiaInvestmentsOption(isPb: isPb, type: .foreignExchange)]
        }
        // Investment funds
        if candidates[.SIDE_INVESTMENT_MENU_FUNDS] != nil {
            wantInvestItems += [SofiaInvestmentsOption(isPb: isPb, type: .funds)]
        }
        // Retirement plans
        if candidates[.SIDE_INVESTMENT_MENU_PENSION_PLANS] != nil {
            wantInvestItems += [SofiaInvestmentsOption(isPb: isPb, type: .pensions)]
        }
        // Roboadvisor
        if candidates[.SIDE_INVESTMENT_MENU_ROBOADVISOR] != nil {
            wantInvestItems += [SofiaInvestmentsOption(isPb: isPb, type: .roboadvisor)]
        }
        if !wantInvestItems.isEmpty {
            // TITLE - I WANT TO INVEST
            options += [SofiaInvestmentsOption(isPb: isPb, type: .titleWantInvest, isInnerTitle: true)]
            options += wantInvestItems
        }
        // TOOLS SECTION
        // Shareholders
        if self.privateMenuWrapper.isStockholdersEnable() == true {
            toolsItems += [SofiaInvestmentsOption(isPb: isPb, type: .shareholders)]
        }
        // Investment alerts
        if candidates[.SIDE_INVESTMENT_MENU_ALERTS] != nil {
            toolsItems += [SofiaInvestmentsOption(isPb: isPb, type: .investmentAlerts)]
        }
        // MIFID test
        if candidates[.SIDE_INVESTMENT_MENU_MIFID_TEST] != nil {
            toolsItems += [SofiaInvestmentsOption(isPb: isPb, type: .newTestMifid)]
        }
        // Markets
        if candidates[.SOFIA_MERCADOS] != nil {
            toolsItems += [SofiaInvestmentsOption(isPb: isPb, type: .sofiaMarket)]
        }
        // Favourites
        if candidates[.SOFIA_FAVORITOS] != nil {
            toolsItems += [SofiaInvestmentsOption(isPb: isPb, type: .sofiaFavourite)]
        }
        // Analysis
        if candidates[.SOFIA_ANALISIS] != nil {
            toolsItems += [SofiaInvestmentsOption(isPb: isPb, type: .sofiaAnalysis)]
        }
        // Santander Guides (Santander Orienta)
        if candidates[.SOFIA_ORIENTA] != nil {
            toolsItems += [SofiaInvestmentsOption(isPb: isPb, type: .sofiaGuidance)]
        }
        if !toolsItems.isEmpty {
            // TITLE - TOOLS
            options += [SofiaInvestmentsOption(isPb: isPb, type: .titleTools, isInnerTitle: true)]
            options += toolsItems
        }
        return options
    }
}

extension SofiaInvestmentsHelper: PrivateMenuSectionHelper {
    var titleKey: String {
        return "menuSofia_link_myInvestiment"
    }
    
    var sidebarProductsTitle: String? {
        return self.privateMenuWrapper.myProductsOffers
    }
    var hasTitle: Bool {
        return (self.presenter?.sofiaInvestmentsOptions.count ?? 0 > 0) ? true : false
    }
    func getOptionsList(completion: @escaping (([PrivateSubmenuOptionRepresentable]) -> Void)) {
        self.completion = completion
        wrapperUpdated()
    }

    func selected(option: PrivateSubmenuOptionRepresentable) {
        guard let option = option as? SofiaInvestmentsOption else {
            return
        }
        navigator.closeSideMenu()
        navigator.setOnlyFirstViewControllerToGP()
        presenter?.backbuttonTouched()
        
        switch option.type {
        case .managedPortfolios:
            navigator.present(selectedProduct: nil, productHome: .managedPortfolios)
        case .notManagedPortfolios:
            navigator.present(selectedProduct: nil, productHome: .notManagedPortfolios)
        case .variableIncome:
            navigator.goToVariableIncome()
        case .ordersSigning:
            offerDelegate?.didSelectBanner(location: .FIRMA_ORDENES)
        case .unadvisedOrders:
            offerDelegate?.didSelectBanner(location: .ORDENES_NO_ASESORADAS)
        case .sofiaOperate:
            offerDelegate?.didSelectBanner(location: .SOFIA_OPERAR)
        case .sofiaOrder:
            offerDelegate?.didSelectBanner(location: .SOFIA_ORDENES)
        case .sofiaMovement:
            offerDelegate?.didSelectBanner(location: .SOFIA_MOVIMIENTOS)
        case .sofiaProposition:
            offerDelegate?.didSelectBanner(location: .SOFIA_PROPUESTAS)
        case .sofiaMarket:
            offerDelegate?.didSelectBanner(location: .SOFIA_MERCADOS)
        case .sofiaFavourite:
            offerDelegate?.didSelectBanner(location: .SOFIA_FAVORITOS)
        case .sofiaAnalysis:
            offerDelegate?.didSelectBanner(location: .SOFIA_ANALISIS)
        case .smartTrader:
            offerDelegate?.didSelectBanner(location: .SOFIA_SMARTTRADER)
        case .sofiaGuidance:
            offerDelegate?.didSelectBanner(location: .SOFIA_ORIENTA)
        case .shareholders:
            navigator.goToStockholders()
        case .invest:
            offerDelegate?.didSelectBanner(location: .MENU_INVESTMENT_INVEST)
        case .testMifid:
            offerDelegate?.didSelectBanner(location: .MENU_INVESTMENT_MIFID)
        case .ebroker:
            offerDelegate?.didSelectBanner(location: .MENU_INVESTMENT_EBROKER)
        case .mifid:
            offerDelegate?.didSelectBanner(location: .SIDE_INVESTMENT_MENU_MIFID_TEST)
        case .foreignExchange:
            offerDelegate?.didSelectBanner(location: .SIDE_INVESTMENT_MENU_FOREINGN_EXCHANGE)
        case .pensions:
            offerDelegate?.didSelectBanner(location: .MENU_INVESTMENT_PENSION)
        case .roboadvisor:
            offerDelegate?.didSelectBanner(location: .SIDE_INVESTMENT_MENU_ROBOADVISOR)
        case .investmentAlerts:
            offerDelegate?.didSelectBanner(location: .SIDE_INVESTMENT_MENU_ALERTS)
        case .funds:
            offerDelegate?.didSelectBanner(location: .SIDE_INVESTMENT_MENU_FUNDS)
        case .guaranteed:
            offerDelegate?.didSelectBanner(location: .SIDE_INVESTMENT_MENU_GUARANTEED)
        case .investmentPosition:
            offerDelegate?.didSelectBanner(location: .SIDE_INVESTMENT_MENU_POSITION)
        case .stocks:
            offerDelegate?.didSelectBanner(location: .SIDE_INVESTMENT_MENU_STOCKS)
        case .fixedRent:
            offerDelegate?.didSelectBanner(location: .SIDE_INVESTMENT_MENU_FIXED_RENT)
        case .newTestMifid:
            offerDelegate?.didSelectBanner(location: .SIDE_INVESTMENT_MENU_MIFID_TEST)
        case .titleWantInvest, .titleTools:
            break
        }
    }
    
    func titleForOption(_ option: PrivateSubmenuOptionRepresentable) -> String {
        let title = localized(option.titleKey).text
        guard let optionSofia = option as? SofiaInvestmentsOption else { return title }
        let value: Int?
        let products = self.privateMenuWrapper.products
        switch optionSofia.type {
        case .managedPortfolios:
            value = products[.managedPortfolio]?.productsRepresentable.count
        case .notManagedPortfolios:
            value = products[.notManagedPortfolio]?.productsRepresentable.count
        case .shareholders:
            value = products[.managedPortfolioVariableIncome]?.productsRepresentable.count
        default:
            return title
        }
        guard
            let productNumber = value,
            productNumber > 0
            else { return title }
        let numberOfProducts = localized("generic_parenthesis_placeholder",
                                         [StringPlaceholder(.number, String(productNumber))]).text
        return "\(title) \(numberOfProducts)"
    }
}

extension SofiaInvestmentsHelper: LocationsResolver {
    var useCaseProvider: UseCaseProvider {
        guard let presenter = presenter else { fatalError() }
        return presenter.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        guard let presenter = presenter else { fatalError() }
        return presenter.useCaseHandler
    }
    
    var genericErrorHandler: GenericPresenterErrorHandler {
        guard let presenter = presenter else { fatalError() }
        return presenter.genericErrorHandler
    }
}
