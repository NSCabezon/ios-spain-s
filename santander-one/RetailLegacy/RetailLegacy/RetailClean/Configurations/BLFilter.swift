//
//  BLFilter.swift
//  BranchLocatorApp
//
//  Created by Ivan Cabezon on 24/01/2019.
//  Copyright © 2019 Globile. All rights reserved.
//

import Foundation
import BranchLocator

func availableFilters() -> [FilterTypeProtocol] {
	return [BLFilter.mostPopular,
			BLFilter.service,
			BLFilter.facilities,
			BLFilter.accessibility,
			BLFilter.pointsOfInterest]
}

enum BLFilter: FilterTypeProtocol {
	case mostPopular
	case service
	case facilities
	case accessibility
	case pointsOfInterest
	
	static var defaultFilters: [Filter] = []
	
	var filters: [Filter] {
		switch self {
		case .mostPopular:
			return [
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
		}
	}
	
}
