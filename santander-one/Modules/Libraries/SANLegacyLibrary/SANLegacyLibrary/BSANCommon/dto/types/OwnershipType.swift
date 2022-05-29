public enum OwnershipType: String , Codable {
	
	case holder = "01"
	
    public init?(type: String) {
        self.init(rawValue: type)
    }
	
    public var type: String {
        get {
            return self.rawValue
        }
    }
}
