import Foundation

public enum ScheduledDayDTO: String, Codable {
    case none
    case previous_day = "A"
    case next_day = "P"
    
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

