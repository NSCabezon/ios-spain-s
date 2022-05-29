public enum StockTradingType: String, CustomStringConvertible , Codable {

    case atBest = "0"
    case atMarket = "4"
    case limited = "1"

    public static func findBy(type: String?) -> StockTradingType? {
        if let type = type, !type.isEmpty {
            switch (type.uppercased()) {
            case atBest.rawValue.uppercased():
                return atBest
            case atMarket.rawValue.uppercased():
                return atMarket
            case limited.rawValue.uppercased():
                return limited
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

    public var description: String {
        return type
    }
}

