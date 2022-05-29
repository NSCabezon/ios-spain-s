public enum World123OptionType {
    case mundoSimulate
    case mundoWhatHave
    case mundoBenefits
    case mundoSignUp
}

public extension World123OptionType {
    var titleKey: String {
        switch self {
        case .mundoSimulate:
            return "pt_menuMundo_link_simulate"
        case .mundoWhatHave:
            return "pt_menuMundo_link_whatHave"
        case .mundoBenefits:
            return "pt_menuMundo_link_benefits"
        case .mundoSignUp:
            return "pt_menuMundo_link_signUp"
        }
    }
    
    var imageKey: String {
        switch self {
        case .mundoSimulate:
            return "icnCalculator"
        case .mundoWhatHave:
            return "iconMundo123"
        case .mundoBenefits:
            return "icnBenefits"
        case .mundoSignUp:
            return "icnSignUp"
        }
    }
    
    var submenuArrow: Bool {
        return false
    }
}
