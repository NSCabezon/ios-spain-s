//
//  FilterRouterMock.swift
//  BranchLocatorTests
//
//  Created by Ivan Cabezon on 13/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation

@testable import BranchLocator

class FilterRouterMock: FiltersRouter {
	
	var didCallCanOpenURL = false
	var didCallOpenURL = false
	
	override func canOpenURL(url: URL) -> Bool {
		didCallCanOpenURL = true
		return true
	}
	
	override func openURL(url: URL) {
		didCallOpenURL = true
	}
}
