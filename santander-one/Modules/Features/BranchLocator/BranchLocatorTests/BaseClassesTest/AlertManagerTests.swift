//
//  AlertManagerTests.swift
//  BranchLocatorTests
//
//  Created by Ivan Cabezon on 27/09/2018.
//  Copyright © 2018 Globile. All rights reserved.
//

import XCTest

@testable import BranchLocator

class AlertManagerTests: XCTestCase {
	
	let viewController = UIViewController()

    override func setUp() {
		
    }

    func testAlertCreatesOK() {
		let title = "title"
		let msg = "msg"
		let acceptTitle = "accept"
		let cancelTitle = "cancel"
		ICOAlertManager.showAlert(title: title, message: msg, acceptTitle: acceptTitle, acceptCompletion: nil, cancelTitle: cancelTitle, cancelCompletion: nil, isDestructive: false, viewController: viewController)
    }
}
