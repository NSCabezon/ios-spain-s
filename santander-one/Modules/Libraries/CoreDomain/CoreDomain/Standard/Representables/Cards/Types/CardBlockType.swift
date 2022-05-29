public enum CardBlockType: String, Codable {
    case stolen = "10"
    case lost
    case deterioration = "38"
    case turnOn = "00"
    case turnOff = "77"
    
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

