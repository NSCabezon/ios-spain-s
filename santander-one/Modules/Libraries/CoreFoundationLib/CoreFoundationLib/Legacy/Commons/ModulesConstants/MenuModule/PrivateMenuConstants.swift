
public enum PrivateMenuPullOffers {
    public static let dateOfficeManager = "CITA_GESTOR_OFICINA"
    public static let sidebarStock = "SIDEBAR_STOCK"
    public static let sidebarPensions = "SIDEBAR_PENSIONS"
    public static let sidebarFunds = "SIDEBAR_FUNDS"
    public static let sidebarInsurance = "SIDEBAR_INSURANCE"
    public static let menuTPV = "MENU_TPV"
    public static let sidebarDeposits = "SIDEBAR_DEPOSITS"

    public static let sidebarInvestmentSubmenu1 = "SIDEMENU_INVEST_SUBSECTION_1"
    public static let sidebarInvestmentSubmenu2 = "SIDEMENU_INVEST_SUBSECTION_2"
    public static let sidebarInvestmentSubmenu3 = "SIDEMENU_INVEST_SUBSECTION_3"
    public static let sidebarInvestmentSubmenu4 = "SIDEMENU_INVEST_SUBSECTION_4"
    public static let sidebarInvestmentSubmenu5 = "SIDEMENU_INVEST_SUBSECTION_5"
    public static let sidebarInvestmentSubmenu6 = "SIDEMENU_INVEST_SUBSECTION_6"
    public static let sidebarInvestmentSubmenu7 = "SIDEMENU_INVEST_SUBSECTION_7"
    public static let sidebarInvestmentSubmenu8 = "SIDEMENU_INVEST_SUBSECTION_8"
    public static let menuInvestmentDeposit = "MENU_INVESTMENT_DEPOSIT"
}

public struct PrivateMenuPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/private_menu"
    public enum Action: String {
        case digitalProfile = "perfil_digital"
    }
    public init() {}
}
