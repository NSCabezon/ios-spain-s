import Foundation

public protocol FilterTypeProtocol {
	var title: String { get }
	var filters: [Filter] { get }
}


enum FilterType: FilterTypeProtocol {
    case mostPopular
    case service
    case facilities
    case accessibility
    case pointsOfInterest
    case pointsOfInterestWithOutPopularAndOthers
	
	static var defaultFilters: [Filter] = []
	
    var filters: [Filter] {
        switch self {
        case .mostPopular:
            return [
//				.available,
//				.noFee,
				.withdrawMoney,
				.depositMoney,
				.individual,
				.santanderATM,
				.workcafe
            ]
        case .service:
            return [.withdrawWithoutCard,
                    .lowDenominationBill,
                    .contactLess,
                    .opensEvenings,
                    .opensSaturdays
            ]
        case .facilities:
            return [.parking,
                    .coworkingSpaces,
                    .wifi,
                    .securityBox,
                    .driveThru
            ]
        case .accessibility:
            return [.wheelchairAccess,
                    .audioGuidance
            ]
        case .pointsOfInterest:
            return [.santanderSelect,
                    .privateBank,
                    .pymesEmpresas,
                    .popularPastor,
                    .partners,
                    .otherATMs
            ]
        case .pointsOfInterestWithOutPopularAndOthers:
        return [.santanderSelect,
                .privateBank,
                .pymesEmpresas,
                .partners]
        }
    }
    
    var title: String {
        switch self {
        case .mostPopular:
            return localizedString("bl_most_popular")
        case .service:
            return localizedString("bl_services")
        case .facilities:
            return localizedString("bl_facilities")
        case .accessibility:
            return localizedString("bl_accessibility")
        case .pointsOfInterest:
            return localizedString("bl_points_of_interest")
        case .pointsOfInterestWithOutPopularAndOthers:
            return localizedString("bl_points_of_interest")
        }
    }
    
}
