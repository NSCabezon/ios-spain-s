public enum PrivateMenuOtherServicesOptionType {
    case next
    case carbonFingerPrint
    case smartServices
}

public extension PrivateMenuOtherServicesOptionType {
    var titleKey: String {
        switch self {
        case .next:
            return "menu_link_shortly"
        case .carbonFingerPrint:
            return "menu_link_fingerPrint"
        case .smartServices:
            return "menu_link_smart"
        }
    }
    
    var icon: String {
        switch self {
        case .next:
            return "icnShortlyMenu"
        case .carbonFingerPrint:
            return "icnCo2"
        case .smartServices:
            return "icnServicesMenu"
        }
    }
    
    var submenuArrow: Bool {
        return self == .smartServices
    }
}
