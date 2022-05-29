public enum PrivateMenuOptions {
    case globalPosition
    case myProducts
    case transfers
    case bills
    case contract
    case marketplace
    case analysisArea
    case santanderOne1
    case santanderOne2
    case sofiaInvestments
    case myHome
    case financing
    case otherServices
    case world123
    case topUps
    case santanderBoots
    case myMoneyManager
    case productsAndOffers
    case myHomeManager
    case importantInformation
    case blik
    case mobileAuthorization
    case becomeClient
    case currencyExchange
    case services
    case memberGetMember

    public var titleKey: String {
        switch self {
        case .globalPosition:
            return "menu_link_pg"
        case .myProducts:
            return "menu_link_myProduct"
        case .transfers:
            return "menu_link_onePayTransfer"
        case .bills:
            return "menu_link_billTax"
        case .contract:
            return "menu_link_contract"
        case .marketplace:
            return "menu_link_marketplace"
        case .analysisArea:
            return "menu_link_tips"
        case .santanderOne1:
            return "menu_link_one"
        case .santanderOne2:
            return "menu_link_buildFuture"
        case .sofiaInvestments:
            return "menuSofia_link_myInvestiment"
        case .myHome:
            return "menu_link_myHome"
        case .financing:
            return "menu_link_financing"
        case .otherServices:
            return "menu_link_otherServices"
        case .world123:
            return "toolbar_title_world123"
        case .topUps:
            return "menu_link_topUps"
        case .santanderBoots:
            return "uk_menu_link_boots"
        case .myMoneyManager:
            return "uk_menu_link_myMoneyManager"
        case .productsAndOffers:
            return "menu_link_offers"
        case .myHomeManager:
            return "uk_menu_link_homeEco"
        case .importantInformation:
            return "uk_menu_link_importantInformation"
        case .blik:
            return "menu_link_blik"
        case .mobileAuthorization:
            return "menu_link_mobileAuthorization"
        case .becomeClient:
            return "menu_link_becomeClient"
        case .currencyExchange:
            return "menu_link_currencyExchange"
        case .services:
            return "menu_link_services"
        case .memberGetMember:
            return "menu_link_memberGetMember"
        }
    }
    
    public var iconKey: String {
        switch self {
        case .globalPosition:
            return "icnPgMenuRed"
        case .myProducts:
            return "icnProductsMenuRed"
        case .transfers:
            return "icnTransferMenuRed"
        case .bills:
            return "icnBillTaxesMenuRed"
        case .contract:
            return "icnExploreProducts"
        case .marketplace:
            return "icnMarket"
        case .analysisArea:
            return "icnTestMenu"
        case .santanderOne1:
            return "icnOneMenu"
        case .santanderOne2:
            return "icnFamily"
        case .sofiaInvestments:
            return "icn_investment"
        case .myHome:
            return "icnMyHome"
        case .financing:
            return "icnFinancing"
        case .otherServices:
            return "icnMenuOtherServices"
        case .world123:
            return "iconMundo123"
        case .topUps:
            return "icnTopUpsMenu"
        case .santanderBoots:
            return "icnBoots"
        case .myMoneyManager:
            return "icnMoneyManagerMenu"
        case .productsAndOffers:
            return "icnOffersUKMenu"
        case .myHomeManager:
            return "icnHomeEcoMenu"
        case .importantInformation:
            return "icnInfoSanMenu"
        case .blik:
            return "icnBlik"
        case .mobileAuthorization:
            return "icnMobileAuthorization"
        case .becomeClient:
            return "icnOffer"
        case .currencyExchange:
            return "icnCurrencyExchange"
        case .services:
            return "icnMcommerce"
        case .memberGetMember:
            return "icnMemberGetMemberRed"
        }
    }
    
    public var submenuArrow: Bool {
        switch self {
        case .otherServices, .myProducts, .sofiaInvestments, .world123:
            return true
        case .globalPosition,
                .transfers,
                .bills,
                .contract,
                .marketplace,
                .analysisArea,
                .santanderOne1,
                .santanderOne2,
                .myHome,
                .topUps,
                .santanderBoots,
                .myMoneyManager,
                .productsAndOffers,
                .myHomeManager,
                .importantInformation,
                .financing,
                .blik,
                .mobileAuthorization,
                .becomeClient,
                .currencyExchange,
                .services,
                .memberGetMember:
            return false
        }
    }
    
    public init?(featuredOptionString: String) {
        switch featuredOptionString {
        case "global_position": self = .globalPosition
        case "my_products": self = .myProducts
        case "investments": self = .sofiaInvestments
        case "one_pay": self = .transfers
        case "bills_and_taxes": self = .bills
        case "offers": self = .contract
        case "analysisArea": self = .analysisArea
        case "santander_one_1": self = .santanderOne1
        case "santander_one_2": self = .santanderOne2
        case "marketplace": self = .marketplace
        case "my_home": self = .myHome
        case "financing": self = .financing
        case "other_services": self = .otherServices
        case "world123": self = .world123
        case "topUps": self = .topUps
        case "blik": self = .blik
        case "mobile_authorization": self = .mobileAuthorization
        case "become_client": self = .becomeClient
        case "currency_exchange": self = .currencyExchange
        case "services": self = .services
        case "member_get_member": self = .memberGetMember
        default: return nil 
        }
    }
    
    public var featuredOptionsId: String {
        switch self {
        case .globalPosition:
            return "global_position"
        case .myProducts:
            return "my_products"
        case .transfers:
            return "one_pay"
        case .bills:
            return "bills_and_taxes"
        case .contract:
            return "offers"
        case .marketplace:
            return "marketplace"
        case .analysisArea:
            return "analysisArea"
        case .santanderOne1:
            return "santander_one_1"
        case .santanderOne2:
            return "santander_one_2"
        case .sofiaInvestments:
            return "investments"
        case .myHome:
            return "my_home"
        case .financing:
            return "financing"
        case .otherServices:
            return "other_services"
        case .world123:
            return "world123"
        case .topUps:
            return "topUps"
        default:
            return ""
        }
    }
    
    public var secondaryIconKey: String? {
        switch self {
        default:
            return nil
        }
    }
}
