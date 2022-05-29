public enum SociusAccountType: String, Codable {

    case mini = "MINI-RL"
    case pyme = "PYME"
    case smartPremium = "SMART-PREMIUM"
    case particular = "PARTICULAR"
    case profesionalPremium = "PROFESIONAL-PREMIUM"

    public static func findBy(type: String?) -> SociusAccountType? {
        if let type = type, !type.isEmpty {
            switch (type.uppercased()) {
            case mini.rawValue.uppercased():
                return mini
            case pyme.rawValue.uppercased():
                return pyme
            case smartPremium.rawValue.uppercased():
                return smartPremium
            case particular.rawValue.uppercased():
                return particular
            case profesionalPremium.rawValue.uppercased():
                return profesionalPremium
            default:
                return nil
            }
        }
        return nil
    }

    public init?(_ type: String) {
        self.init(rawValue: type)
    }

    public var type: String {
        get {
            return self.rawValue
        }
    }

    public var name: String {
        get {
            return String(describing: self)
        }
    }
}
