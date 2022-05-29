//
//  NavigationTests.swift
//  BranchLocatorTests
//
//  Created by Ivan Cabezon on 27/09/2018.
//  Copyright © 2018 Globile. All rights reserved.
//

import XCTest

@testable import BranchLocator

class NavigationTests: XCTestCase {
	
	var navigationController: LocatorNavigationController!

    override func setUp() {
		super.setUp()
		
		navigationController = LocatorNavigationController(rootViewController: UIViewController())
        let _ = navigationController.view
    }

	func testConfigIsOK() {
		XCTAssertNotNil(navigationController.delegate)
		XCTAssertNotNil(navigationController.interactivePopGestureRecognizer?.delegate)
	}
	
	func testNavigationWillShowController() {
		let viewController = UIViewController()
		navigationController.navigationController(navigationController, willShow: viewController, animated: true)
		XCTAssertNotNil(viewController.navigationItem.backBarButtonItem)
	}
	
	override func tearDown() {
		
	}
}
