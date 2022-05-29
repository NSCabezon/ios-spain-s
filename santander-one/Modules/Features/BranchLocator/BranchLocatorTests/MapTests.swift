//
//  LocatorAppTests.swift
//  LocatorAppTests
//
//  Created by Ivan Cabezon on 19/7/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import XCTest
import MapKit

@testable import BranchLocator

class MapTests: XCTestCase {
	
	var mainViewController: MapViewController!
	
    override func setUp() {
        super.setUp()
		
		mainViewController = MapRouter.createModule(urlLauncher: UIApplication())
		_ = mainViewController.view
    }
	
    func testMapExists() {
		XCTAssert(mainViewController.mapView != nil)
    }
	
	func testMapShowsUserLocation() {
		XCTAssert(mainViewController.mapView.showsUserLocation == true)
	}
	
	func testServiceLogicForAddingPOIs() {
		// TODO: test logic after receiving the data form mock server and drawing in map
	}
	
    func testHideSearchHereButtonWhenMoveToCurrentPosition() {
        mainViewController.moveMapToUserLocationAction("")
        XCTAssert(mainViewController.searchAgainButton.alpha == 0.0)
    }
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
}
