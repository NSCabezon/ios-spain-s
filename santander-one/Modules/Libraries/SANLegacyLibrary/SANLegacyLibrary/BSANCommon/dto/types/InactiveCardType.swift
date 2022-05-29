public enum InactiveCardType: String , Codable {

    case inactive = ""
    case temporallyOff = "X"

    public init?(type: String) {
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
