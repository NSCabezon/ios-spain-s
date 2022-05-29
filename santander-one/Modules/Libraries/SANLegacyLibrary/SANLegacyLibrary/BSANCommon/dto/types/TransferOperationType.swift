public enum TransferOperationType: String, Codable {
    case NATIONAL_SEPA = "PM"
    case INTERNATIONAL_SEPA = "EX"
    
    public static func findBy(type: String?) -> TransferOperationType? {
        if let type = type, !type.isEmpty {
            switch (type.uppercased()) {
            case NATIONAL_SEPA.rawValue.uppercased():
                return NATIONAL_SEPA
            case INTERNATIONAL_SEPA.rawValue.uppercased():
                return INTERNATIONAL_SEPA
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
            return String(describing:self)
        }
    }
}
