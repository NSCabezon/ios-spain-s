//
//  DetailInteractorMock.swift
//  BranchLocatorTests
//
//  Created by vectoradmin on 26/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation

@testable import BranchLocator

class DetailInteractorMock: POIDetailInteractor {

	override func getPhone(for mainPOI: Bool) -> String? {
		return "672384765"
	}
	
	override func appointmentURL(for mainPOI: Bool) -> URL? {
		return URL(string: "www.google.com")
	}
}

