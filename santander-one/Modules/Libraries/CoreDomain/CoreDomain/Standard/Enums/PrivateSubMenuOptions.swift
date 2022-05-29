public enum PrivateSubMenuOptions: Int, Comparable {
    case sidebarStock = 0
    case sidebarPensions
    case sidebarFunds
    case sidebarInsurance
    case sidebarDeposits
    case sidemenuInvestSubsection1
    case sidemenuInvestSubsection2
    case sidemenuInvestSubsection3
    case sidemenuInvestSubsection4
    case sidemenuInvestSubsection5
    case sidemenuInvestSubsection6
    case sidemenuInvestSubsection7
    case sidemenuInvestSubsection8
    case menuInvestmentDeposit
    
    public static func < (lhs: PrivateSubMenuOptions, rhs: PrivateSubMenuOptions) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public extension PrivateSubMenuOptions {
    var titleKey: String {
        switch self {
        case .sidebarStock:
            return "menuMyProduct_link_stocks"
        case .sidebarPensions:
            return "menuMyProduct_link_plans"
        case .sidebarFunds:
            return "menuMyProduct_link_funds"
        case .sidebarInsurance:
            return "menuMyProduct_link_insurance"
        case .sidebarDeposits:
            return "cardsOption_button_contractDeposits"
        case .sidemenuInvestSubsection1:
            return "cardsOption_button_contractDeposits"
        case .sidemenuInvestSubsection2,
                .sidemenuInvestSubsection3,
                .sidemenuInvestSubsection4,
                .sidemenuInvestSubsection5,
                .sidemenuInvestSubsection6,
                .sidemenuInvestSubsection7,
                .sidemenuInvestSubsection8,
                .menuInvestmentDeposit:
            return ""
        }
    }
    
    var imageKey: String {
        switch self {
        case .sidebarStock:
            return "icnStocksMenu"
        case .sidebarPensions:
            return "icnPlansMenu"
        case .sidebarFunds:
            return "icnFundsMenu"
        case .sidebarInsurance:
            return "icnInsuranceMenu"
        case .sidebarDeposits:
            return "icnLoansMenu"
        case .sidemenuInvestSubsection1:
            return "icnDepositsMenu"
        case .sidemenuInvestSubsection2,
                .sidemenuInvestSubsection3,
                .sidemenuInvestSubsection4,
                .sidemenuInvestSubsection5,
                .sidemenuInvestSubsection6,
                .sidemenuInvestSubsection7,
                .sidemenuInvestSubsection8,
                .menuInvestmentDeposit:
            return ""
        }
    }
}
