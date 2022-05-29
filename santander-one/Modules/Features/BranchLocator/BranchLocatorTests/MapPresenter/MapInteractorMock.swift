//
//  MapInteractorMock.swift
//  LocatorAppTests
//
//  Created by Ivan Cabezon on 3/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation
import MapKit

@testable import BranchLocator

class MapInteractorMock: MapInteractor {
	
	var didCallGetNearPOIs = false
	var shouldReturnFilters = false
	
	override func getNearPOIs(to location: CLLocationCoordinate2D) {
		didCallGetNearPOIs = true
	}
	
	override func getSelectedFilters() -> [Filter] {
		if shouldReturnFilters {
			return [.available]
		} else {
			return []
		}
	}
}
