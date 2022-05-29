import Foundation
import ObjectMapper

public enum Filter {
    case available				// Not available
    case noFee					// Not available
    case withdrawMoney
    case lowDenominationBill
    case individual
    case santanderATM  			// We can't filter by only santander ATMs since it doesn't exist a subtype santander atm and the ATM type englobes both
    case workcafe
    case withdrawWithoutCard
    case coworkingSpaces
    case wifi
    case securityBox
    case driveThru
    case wheelchairAccess
    case audioGuidance
    case santanderSelect
    case privateBank
    case pymesEmpresas
    case popularPastor
    case partners
    case otherATMs
	case depositMoney      		// Multicajero
    case contactLess
    case opensEvenings
    case opensSaturdays
    case parking
	
	// "PAY" filter not implemented YET
    
    func icon(selected: Bool) -> UIImage {
        switch self {
        case .otherATMs:
            return UIImage(resourceName: "atm") ?? UIImage()
        case .partners:
            return UIImage(resourceName: "partners") ?? UIImage()
        case .popularPastor:
            return UIImage(resourceName: "popular") ?? UIImage()
        case .workcafe:
			if selected {
				return UIImage(resourceName: "workcafe") ?? UIImage()
			} else {
				return UIImage(resourceName: "workcafeOff") ?? UIImage()
			}
        case .lowDenominationBill,
             .withdrawWithoutCard,
             .depositMoney,
             .contactLess,
             .opensEvenings,
             .opensSaturdays,
             .parking,
             .coworkingSpaces,
             .wifi,
             .securityBox,
             .driveThru,
             .wheelchairAccess,
             .audioGuidance,
			 .noFee,
			 .withdrawMoney,
			 .available:
            if selected {
				return UIImage(resourceName: "active") ?? UIImage()
            }
        default:
			return UIImage(resourceName: "sanRed") ?? UIImage()
        }
		return UIImage()
    }
    
    var title: String {
        switch self {
        case .available:
            return localizedString("bl_now_available")
        case .noFee:
            return localizedString("bl_no_fee")
        case .withdrawMoney:
            return localizedString("bl_withdraw_money")
        case .lowDenominationBill:
            return localizedString("bl_low_denomination_bills")
        case .individual:
            return localizedString("bl_individuals")
        case .santanderATM:
            return localizedString("bl_santander_atms_filters")
        case .workcafe:
            return localizedString("bl_workcafe")
        case .withdrawWithoutCard:
            return localizedString("bl_withdraw_without_card")
        case .coworkingSpaces:
            return localizedString("bl_coworking_spaces_filters")
        case .wifi:
            return localizedString("bl_wifi_filters")
        case .securityBox:
            return localizedString("bl_security_box_filters")
        case .driveThru:
            return localizedString("bl_drive_thru")
        case .wheelchairAccess:
            return localizedString("bl_wheelchair_access")
        case .audioGuidance:
            return localizedString("bl_audio_guidance")
        case .santanderSelect:
            return localizedString("bl_select")
        case .privateBank:
            return localizedString("bl_private_banking")
        case .pymesEmpresas:
            return "\(localizedString("bl_pymes"))/\(localizedString("bl_companies"))"
        case .popularPastor:
            return "\(localizedString("bl_popular"))/\(localizedString("bl_pastor"))"
        case .partners:
            return localizedString("bl_partners")
        case .otherATMs:
            return localizedString("bl_other_atms")
        case .depositMoney:
            return localizedString("bl_deposit_money")
        case .contactLess:
            return localizedString("bl_contactless")
        case .opensEvenings:
            return localizedString("bl_opens_evenings")
        case .opensSaturdays:
            return localizedString("bl_opens_saturdays")
        case .parking:
            return localizedString("bl_parking_filters")
        
        }
    }
}

extension Filter: RawRepresentable {
	public init?(rawValue: String) {
        switch rawValue {
        case "available": self = .available
        case "noFee": self = .noFee
        case "withdrawMoney": self = .withdrawMoney
        case "lowDenominationBill": self = .lowDenominationBill
        case "individual": self = .individual
        case "santanderATM": self = .santanderATM
        case "workcafe": self = .workcafe
        case "withdrawWithoutCard": self = .withdrawWithoutCard
        case "coworkingSpaces": self = .coworkingSpaces
        case "wifi": self = .wifi
        case "securityBox": self = .securityBox
        case "driveThru": self = .driveThru
        case "wheelchairAccess": self = .wheelchairAccess
        case "audioGuidance": self = .audioGuidance
        case "santanderSelect": self = .santanderSelect
        case "privateBank": self = .privateBank
        case "pymesEmpresas": self = .pymesEmpresas
        case "popularPastor": self = .popularPastor
        case "partners": self = .partners
        case "otherATMs": self = .otherATMs
        case "depositMoney": self = .depositMoney
        case "contactLess": self = .contactLess
        case "opensEvenings": self = .opensEvenings
        case "opensSaturdays": self = .opensSaturdays
        case "parking": self = .parking
        default:
            self = .available
        }
    }
	public var rawValue: String {
        switch self {
        case .available:return "available"
        case .noFee: return "noFee"
        case .withdrawMoney: return "withdrawMoney"
        case .lowDenominationBill: return "lowDenominationBill"
        case .individual: return "individual"
        case .santanderATM: return "santanderATM"
        case .workcafe: return "workcafe"
        case .withdrawWithoutCard: return "withdrawWithoutCard"
        case .coworkingSpaces: return "coworkingSpaces"
        case .wifi: return "wifi"
        case .securityBox: return "securityBox"
        case .driveThru: return "driveThru"
        case .wheelchairAccess: return "wheelChairAccess"
        case .audioGuidance: return "audioGuidance"
        case .santanderSelect: return "santanderSelect"
        case .privateBank: return "privateBank"
        case .pymesEmpresas: return "pymesEmpresas"
        case .popularPastor: return "popularPastor"
        case .partners: return "partners"
        case .otherATMs: return "otherATMs"
        case .depositMoney: return "depositMoney"
        case .contactLess: return "contactLess"
        case .opensEvenings: return "opensEvenings"
        case .opensSaturdays: return "opensSaturdays"
        case .parking: return "ownParking"
        }
    }
}



