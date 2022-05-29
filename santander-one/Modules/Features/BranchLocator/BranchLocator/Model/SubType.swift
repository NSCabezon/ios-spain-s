import Foundation
import ObjectMapper

public enum SubTypeCode {
	case branch
	case selectEmbassy
	case select
	case workCafe
	case popular
	case companies
	case individuals
	case universities
	case residents
	case corresponsals
	case privateBanking
	case pastor
	case banefe
	case mall
	case colaborators
	case financials
	case pyme
	case oxxo
	case eleven
	case circleK
	case extraShop
	case kShop
	case telecomm
	case super247
	case atm
	case santanderATM
	case nonSantanderATM
    case post
}



extension SubTypeCode: RawRepresentable {
	public init?(rawValue: String) {
		switch rawValue {
		case "BRANCH": self = .branch
		case "SELECT_EMBASSY": self = .selectEmbassy
		case "SELECT": self = .select
		case "WORKCAFE": self = .workCafe
		case "CLIENTES_POPULAR": self = .popular
		case "POPULAR-EURO AUTOMATIC CASH": self = .popular
		case "EMPRESAS": self = .companies
		case "PARTICULARES": self = .individuals
		case "UNIVERSIDADES": self = .universities
		case "RESIDENTES": self = .residents
		case "CORRESPONSALES": self = .corresponsals
		case "BANCAPRIVADA": self = .privateBanking
		case "CLIENTES_PASTOR": self = .pastor
		case "CLIENTES_BANEFE": self = .banefe
		case "GRANDES_SUPERFICIES": self = .mall
		case "AG_COLABORADORES": self = .colaborators
		case "AG_FINANCIEROS": self = .financials
		case "PYME": self = .pyme
		case "OXXO": self = .oxxo
		case "ELEVEN": self = .eleven
		case "CIRCLE_K": self = .circleK
		case "TIENDA_EXTRA": self = .extraShop
		case "TIENDA_K": self = .kShop
		case "TELECOMM": self = .telecomm
		case "SUPER7_24": self = .super247
		case "ATM": self = .atm
		case "SANTANDER_ATM": self = .santanderATM
		case "NON_SANTANDER_ATM": self = .nonSantanderATM
        case "CORREOS_PRES": self = .post
		default: self = .branch
		}
	}
	
	public var rawValue: String {
		switch self {
		case .branch: return "BRANCH"
		case .selectEmbassy: return "SELECT_EMBASSY"
		case .select: return "SELECT"
		case .workCafe: return "WORKCAFE"
		case .popular: return "CLIENTES_POPULAR"
		case .companies: return "EMPRESAS"
		case .individuals: return "PARTICULARES"
		case .universities: return "UNIVERSIDADES"
		case .residents: return "RESIDENTES"
		case .corresponsals: return "CORRESPONSALES"
		case .privateBanking: return "BANCAPRIVADA"
		case .pastor: return "CLIENTES_PASTOR"
		case .banefe: return "CLIENTES_BANEFE"
		case .mall: return "GRANDES_SUPERFICIES"
		case .colaborators: return "AG_COLABORADORES"
		case .financials: return "AG_FINANCIEROS"
		case .pyme: return "PYME"
		case .oxxo: return "OXXO"
		case .eleven: return "ELEVEN"
		case .circleK: return "CIRCLE_K"
		case .extraShop: return "TIENDA_EXTRA"
		case .kShop: return "TIENDA_K"
		case .telecomm: return "TELECOMM"
		case .super247: return "SUPER7_24"
		case .atm: return "ATM"
		case .santanderATM: return "SANTANDER_ATM"
		case .nonSantanderATM: return "NON_SANTANDER_ATM"
        case .post: return "CORREOS_PRES"
		}
	}
}


public struct SubType: Mappable {
	public var code: SubTypeCode?
	public var multi: JSON?
    
    var isPopularOrPastor: Bool {
        return code == .popular || code == .pastor
    }
	
	public init?(map: Map) {
		
	}
	
	mutating public func mapping(map: Map) {
		code		<- (map["code"], EnumTransform<SubTypeCode>())
		multi		<- map["multi"]
	}
}


// swiftlint:disable type_name
public struct attribTest: Mappable {
// swiftlint:enable type_name
    public var code: String?
    public var multi: JSON?
    
    
    public init?(map: Map) {
        
    }
    
    mutating public func mapping(map: Map) {
        code        <- (map["code"])
        multi        <- map["multi"]
    }
}
