public enum CardDataIndicator: String, Codable {
    
    case firstPage = "L"
    case otherPages = "R"
    
    public static func findBy(type: String?) -> CardDataIndicator? {
        if let type = type, !type.isEmpty {
            switch (type.uppercased()) {
            case firstPage.rawValue.uppercased():
                return firstPage
            case otherPages.rawValue.uppercased():
                return otherPages
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


