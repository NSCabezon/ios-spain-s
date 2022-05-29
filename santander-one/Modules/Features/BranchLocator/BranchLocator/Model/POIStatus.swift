enum POIStatus {
	case active
	case inactive
	case unknown
}

extension POIStatus: RawRepresentable {
	init?(rawValue: String) {
		switch rawValue.uppercased() {
		case "ACTIVE": self = .active
		default: self = .unknown
		}
	}
	
	var rawValue: String {
		switch self {
		case .active: return "ACTIVE"
		default: return ""
		}
	}
}
