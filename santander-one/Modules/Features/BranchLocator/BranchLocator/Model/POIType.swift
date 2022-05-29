import Foundation
import ObjectMapper

public enum Type {
	case atm
	case branch
	case corresponsales
	
	var objIcon: UIImage {
		switch self {
		case .atm,
			 .branch:
			return UIImage(resourceName: "sanRed") ?? UIImage()
		case .corresponsales:
			return UIImage(resourceName: "partners") ?? UIImage()
		}
	}
	
	public var name: String {
		switch self {
		case .atm:
			return localizedString("bl_atm")
		case .branch:
			return localizedString("bl_branch")
		case .corresponsales:
			return localizedString("bl_branchInfoCorresponsales")
		}
	}
	
	var phoneTitle: String {
		switch self {
		case .atm:
			return localizedString("bl_incidents_phone")
		case .branch, .corresponsales:
			return localizedString("bl_phone")
		}
	}
	
	var bgImage: UIImage {
		switch self {
		case .atm, .branch, .corresponsales:
			return UIImage(resourceName: "touchpointWhite") ?? UIImage()
		}
	}
	
	var selectedBgImage: UIImage {
		switch self {
		case .atm, .branch, .corresponsales:
			return UIImage(resourceName: "touchpointBigRed") ?? UIImage()
		}
	}
	
	var selectedBgImagePopular: UIImage {
		return UIImage(resourceName: "touchpointBigMagenta") ?? UIImage()
	}
    
    var analiticsValue: String {
        switch self {
        case .atm:
            return "atm"
        case .branch:
            return "branch"
        case .corresponsales:
            return "corresponsales"
        }
    }
}

extension Type: RawRepresentable {
	public init?(rawValue: String) {
		switch rawValue {
		case "ATM": self = .atm
		case "BRANCH": self = .branch
		case "CORRESPONSALES": self = .corresponsales
		default: self = .branch
		}
	}
	
	public var rawValue: String {
		switch self {
		case .atm: return "ATM"
		case .branch: return "BRANCH"
		case .corresponsales: return "CORRESPONSALES"
		}
	}
}


public struct POIType: Mappable {
	public var code: Type!
	var multi: JSON?
	
	public init?(map: Map) {
		
	}
	
	mutating public func mapping(map: Map) {
		code		<- (map["code"], EnumTransform<Type>())
		multi		<- map["multi"]
	}
}

