public enum InsuranceParticipantsType: String , Codable {
	
	case participantsToShow = "48"
	
    public init?(_ type : String) {
		 self.init(rawValue: type)
	}
    
    public var type: String {
        get {
            return self.rawValue
        }
    }
}
