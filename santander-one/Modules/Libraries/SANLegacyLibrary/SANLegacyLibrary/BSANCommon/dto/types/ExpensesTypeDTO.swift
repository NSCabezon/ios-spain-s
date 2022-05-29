public enum ExpensesType: String, Codable {
    case shared = "S"
    case our = "O"
    case benf = "B"
    
    public static func parse(_ expenses: String?) -> ExpensesType? {
        if let expenses = expenses, !expenses.isEmpty {
            switch expenses.uppercased() {
            case shared.rawValue.uppercased():
                return shared
            case our.rawValue.uppercased():
                return our
            case benf.rawValue.uppercased():
                return benf
            default:
                return nil
            }
        }
        return nil
    }
    
    init?(_ type: String) {
        self.init(rawValue: type)
    }
    
    public var name: String {
        get {
            return self.rawValue
        }
    }
}

