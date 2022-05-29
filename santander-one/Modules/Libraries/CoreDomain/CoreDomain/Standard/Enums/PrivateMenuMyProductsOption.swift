public enum PrivateMenuMyProductsOption: PrivateSubmenuOptionRepresentable {
    case accounts
    case cards
    case stocks
    case deposits
    case loans
    case pensions
    case funds
    case insuranceSavings
    case insuranceProtection
    case savingProducts
    case tpvs
    
    public static var pbOrder: [PrivateMenuMyProductsOption] {
        return [.accounts,
                .cards,
                .savingProducts,
                .deposits,
                .loans,
                .stocks,
                .pensions,
                .funds,
                .insuranceSavings,
                .insuranceProtection]
    }
    
    public static var notPbOrder: [PrivateMenuMyProductsOption] {
        return [.accounts,
                .cards,
                .savingProducts,
                .stocks,
                .loans,
                .deposits,
                .pensions,
                .funds,
                .insuranceSavings,
                .insuranceProtection]
    }
    
    public static var actionPbOrder: [PrivateSubmenuAction] {
        return [.myProductOffer(.accounts),
                .myProductOffer(.cards),
                .myProductOffer(.savingProducts),
                .myProductOffer(.deposits),
                .myProductOffer(.loans),
                .myProductOffer(.stocks),
                .myProductOffer(.pensions),
                .myProductOffer(.funds),
                .myProductOffer(.insuranceSavings),
                .myProductOffer(.insuranceProtection)]
    }
    
    public static var actionNotPbOrder: [PrivateSubmenuAction] {
        return [.myProductOffer(.accounts),
                .myProductOffer(.cards),
                .myProductOffer(.savingProducts),
                .myProductOffer(.stocks),
                .myProductOffer(.loans),
                .myProductOffer(.deposits),
                .myProductOffer(.pensions),
                .myProductOffer(.funds),
                .myProductOffer(.insuranceSavings),
                .myProductOffer(.insuranceProtection)]
    }
    
    public var icon: String? {
        return nil
    }
    
    public var titleKey: String {
        switch self {
        case .accounts:
            return "menuMyProduct_link_account"
        case .cards:
            return "menuMyProduct_link_cards"
        case .savingProducts:
            return "menuMyProduct_link_savings"
        case .stocks:
            return "menuMyProduct_link_stocks"
        case .deposits:
            return "menuMyProduct_link_deposits"
        case .loans:
            return "menuMyProduct_link_loans"
        case .pensions:
            return "menuMyProduct_link_plans"
        case .funds:
            return "menuMyProduct_link_funds"
        case .insuranceSavings:
            return "menuMyProduct_link_insuranceSaving"
        case .insuranceProtection:
            return "menuMyProduct_link_insurance"
        case .tpvs:
            return "menu_link_tpvs"
        }
    }
    
    public var imageKey: String {
        switch self {
        case .accounts:
            return "icnAccountsMenuRed"
        case .cards:
            return "icnCardsMenuRed"
        case .savingProducts:
            return "icnSavingsMenu"
        case .stocks:
            return "icnStocksMenuRed"
        case .deposits:
            return "icnDepositsMenuRed"
        case .loans:
            return "icnLoansMenuRed"
        case .pensions:
            return "icnPlansMenuRed"
        case .funds:
            return "icnFundsMenuRed"
        case .insuranceSavings:
            return "icnInsuranceSavingMenuRed"
        case .insuranceProtection:
            return "icnInsuranceMenuRed"
        case .tpvs:
            return "icnTpVs"
        }
    }
}
