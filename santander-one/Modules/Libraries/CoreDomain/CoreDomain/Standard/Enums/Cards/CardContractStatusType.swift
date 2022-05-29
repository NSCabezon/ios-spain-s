public enum CardContractStatusType : String, Codable {
    case active = "en vigor"
    case inactive = "inactiva"
    case blocked = "bloqueado"
    case cancelled = "cancelada"
    case replacement = "reemplazo"
    case issued = "emitida"
    case other = ""
    
    public static func parse(_ type: String?) -> CardContractStatusType? {
        if let type = type, !type.isEmpty {
            switch (type.lowercased()) {
            case active.rawValue.lowercased():
                return active
            case inactive.rawValue.lowercased():
                return inactive
            case blocked.rawValue.lowercased():
                return blocked
            case cancelled.rawValue.lowercased():
                return cancelled
            case replacement.rawValue.lowercased():
                return replacement
            case issued.rawValue.lowercased():
                return issued
            default:
                return other
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
}


