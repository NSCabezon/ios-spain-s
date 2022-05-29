//
//  MapRouterMock.swift
//  LocatorAppTests
//
//  Created by Ivan Cabezon on 3/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation

@testable import BranchLocator

class MapRouterMock: MapRouter {
	var goToFiltersCalled = false
	var didCallCanOpenURL = false
	var didCallOpenURL = false
	
	override func goToFilters(with filterDelegate: FilterDelegate, shouldShowTitle: Bool) {
		goToFiltersCalled = true
	}
	
	override func canOpenURL(url: URL) -> Bool {
		didCallCanOpenURL = true
		return true
	}
	
	override func openURL(url: URL) {
		didCallOpenURL = true
	}
}
