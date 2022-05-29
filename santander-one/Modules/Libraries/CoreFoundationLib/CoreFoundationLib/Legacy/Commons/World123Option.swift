import CoreDomain

extension World123OptionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .mundoSimulate:
            return AccessibilitySideWorld123.btnMundoSimulate
        case .mundoWhatHave:
            return AccessibilitySideWorld123.btnMundoWhatHave
        case .mundoBenefits:
            return AccessibilitySideWorld123.btnMundoBenefits
        case .mundoSignUp:
            return AccessibilitySideWorld123.btnMundoSignUp
        }
    }
}
