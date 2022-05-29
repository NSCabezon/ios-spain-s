public enum PrivateSubMenuOptionType {
    case myProducts
    case world123
    case sofia
    case otherServices
    case smartServices
}

extension PrivateSubMenuOptionType {
    public var title: String? {
        switch self {
        case .myProducts:
            return "menu_link_myProduct"
        case .world123:
            return "toolbar_title_world123"
        case .sofia:
            return "menuSofia_link_myInvestiment"
        case .otherServices:
            return "menu_link_otherServices"
        case .smartServices:
            return "menu_link_forYou"
        }
    }
    
    public var superTitle: String? {
        switch self {
        case .smartServices:
            return "menu_link_otherServices"
        case .myProducts, .world123, .sofia, .otherServices:
            return ""
        }
    }
}
