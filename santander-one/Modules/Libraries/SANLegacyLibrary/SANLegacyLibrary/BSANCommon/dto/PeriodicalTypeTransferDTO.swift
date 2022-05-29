import Foundation

public enum PeriodicalTypeTransferDTO: String, Codable {
    case none
    case monthly = "1"
    case trimestral = "3"
    case semiannual = "6"
    case weekly = "7"
    case bimonthly = "2"
    case annual = "12"
    
    public static func findBy(type: String?) -> PeriodicalTypeTransferDTO? {
        if let type = type, !type.isEmpty {
            switch (type.uppercased()) {
            case "201":
                return monthly
            case "203":
                return trimestral
            case "206":
                return semiannual
            case "207":
                return .weekly
            case "202":
                return .bimonthly
            case "212":
                return .annual
            default:
                return none
            }
        }
        return nil
    }
    
    public init?(_ type: String) {
        self.init(rawValue: type)
    }
    
    public var type: String {
        get {
            switch self {
            case .none: return "200"
            case .monthly: return "201"
            case .trimestral: return "203"
            case .semiannual: return "206"
            case .weekly: return "207"
            case .bimonthly: return "202"
            case .annual: return "212"
            }
        }
    }
    
    public var name: String {
        get {
            return String(describing:self)
        }
    }
}
