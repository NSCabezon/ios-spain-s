//
//  DetailRouterMock.swift
//  BranchLocatorTests
//
//  Created by vectoradmin on 26/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation

@testable import BranchLocator

class DetailRouterMock: POIDetailRouter {
    
	var didCallCanOpenURL = false
	var didCallOpenURL = false
	
	var didCallNavigateToDestination = false
	
	override func canOpenURL(url: URL) -> Bool {
		didCallCanOpenURL = true
		return true
	}
	
	override func openURL(url: URL) {
		didCallOpenURL = true
	}
	
	override func navigateToDestination(latitude: Double, longitude: Double) {
		didCallNavigateToDestination = true
	}
}
