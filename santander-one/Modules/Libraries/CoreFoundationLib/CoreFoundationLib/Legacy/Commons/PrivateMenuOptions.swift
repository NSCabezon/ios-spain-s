import CoreDomain

extension PrivateMenuOptions: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .globalPosition:
            return AccessibilitySideMenu.btnPg.rawValue
        case .myProducts:
            return AccessibilitySideMenu.btnMyProducts.rawValue
        case .transfers:
            return AccessibilitySideMenu.btnOnePayTransfer.rawValue
        case .bills:
            return AccessibilitySideMenu.btnBillTax.rawValue
        case .contract:
            return AccessibilitySideMenu.btnContract.rawValue
        case .marketplace:
            return AccessibilitySideMenu.btnMarketplace.rawValue
        case .analysisArea:
            return AccessibilitySideMenu.btnTips.rawValue
        case .santanderOne1:
            return AccessibilitySideMenu.btnSantanderOne1.rawValue
        case .santanderOne2:
            return AccessibilitySideMenu.btnSantanderOne2.rawValue
        case .myHome:
            return AccessibilitySideMenu.btnMyHome.rawValue
        case .financing:
            return AccessibilitySideMenu.btnFinancing.rawValue
        case .sofiaInvestments:
            return AccessibilitySideMenu.btnMyInvestiment.rawValue
        case .otherServices:
            return AccessibilitySideMenu.btnOtherServices.rawValue
        case .world123:
            return AccessibilitySideMenu.btnWorld123.rawValue
        case .topUps:
            return AccessibilitySideMenu.btnTopUps.rawValue
        default:
            return ""
        }
    }
    
    public var location: PullOfferLocationRepresentable? {
        switch self {
        case .santanderOne1:
            return PullOffersLocationsFactoryEntity().santanderOne1.first
        case .santanderOne2:
            return PullOffersLocationsFactoryEntity().santanderOne2.first
        case .myHome:
            return PullOffersLocationsFactoryEntity().privateMenuMyHome.first
        case .contract:
            return PullOffersLocationsFactoryEntity().privateMenuSanflix.first
        default:
            return nil
        }
    }
}
