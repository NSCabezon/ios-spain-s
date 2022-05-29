import CoreDomain

extension PrivateSubMenuOptions {
    public var location: String {
        switch self {
        case .sidebarStock:
            return PrivateMenuPullOffers.sidebarStock
        case .sidebarPensions:
            return PrivateMenuPullOffers.sidebarPensions
        case .sidebarFunds:
            return PrivateMenuPullOffers.sidebarFunds
        case .sidebarInsurance:
            return PrivateMenuPullOffers.sidebarInsurance
        case .sidebarDeposits:
            return PrivateMenuPullOffers.sidebarDeposits
        case .sidemenuInvestSubsection1:
            return PrivateMenuPullOffers.sidebarInvestmentSubmenu1
        case .sidemenuInvestSubsection2:
            return PrivateMenuPullOffers.sidebarInvestmentSubmenu2
        case .sidemenuInvestSubsection3:
            return PrivateMenuPullOffers.sidebarInvestmentSubmenu3
        case .sidemenuInvestSubsection4:
            return PrivateMenuPullOffers.sidebarInvestmentSubmenu4
        case .sidemenuInvestSubsection5:
            return PrivateMenuPullOffers.sidebarInvestmentSubmenu5
        case .sidemenuInvestSubsection6:
            return PrivateMenuPullOffers.sidebarInvestmentSubmenu6
        case .sidemenuInvestSubsection7:
            return PrivateMenuPullOffers.sidebarInvestmentSubmenu7
        case .sidemenuInvestSubsection8:
            return PrivateMenuPullOffers.sidebarInvestmentSubmenu8
        case .menuInvestmentDeposit:
            return PrivateMenuPullOffers.menuInvestmentDeposit
        }
    }
    
    public var accessibilityId: String {
        switch self {
        case .sidebarFunds:
            return AccessibilitySideInteresting.btnContractFunds
        case .sidebarDeposits:
            return AccessibilitySideInteresting.btnContractDeposits
        case .sidemenuInvestSubsection1:
            return AccessibilitySideInvestment.btnContractInvestmentDeposits
        case .sidebarStock,
                .sidebarInsurance,
                .sidebarPensions,
                .sidemenuInvestSubsection2,
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
