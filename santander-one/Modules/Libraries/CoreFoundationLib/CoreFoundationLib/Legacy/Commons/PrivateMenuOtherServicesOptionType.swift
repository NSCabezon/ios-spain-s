import CoreDomain

extension PrivateMenuOtherServicesOptionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .smartServices:
            return AccessibilitySideMenu.btnSmart.rawValue
        case .next:
            return AccessibilitySideMenu.btnShortly.rawValue
        case .carbonFingerPrint:
            return AccessibilitySideMenu.btnCarbonFingerPrint.rawValue
        }
    }
}
