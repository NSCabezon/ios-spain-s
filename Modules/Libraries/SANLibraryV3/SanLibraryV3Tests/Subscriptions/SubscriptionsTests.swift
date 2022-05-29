//
//  SubscriptionsTests.swift
//  SanLibraryV3Tests
//
//  Created by Rubén Márquez Fernández on 10/5/21.
//  Copyright © 2021 com.ciber. All rights reserved.
//

import CoreFoundationLib
import XCTest
@testable import SanLibraryV3

class SubscriptionsTests: BaseLibraryTests {

    override func setUpWithError() throws {
        environmentDTO = BSANEnvironments.environmentPro
        setLoginUser(newLoginUser: LOGIN_USER.SUBSCRIPTIONS_CARDS)
        resetDataRepository()
        super.setUp()
    }

    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func test_service_activate_shouldBeSuccess() {
        // Only testeable in PRO
        let token = ""
        guard let response = try? bsanSubscriptionManager?.activate(token: token, instaID: "000000000000000049552916") else {
            return XCTFail("Fail to load get sign pattern")
        }
        XCTAssertTrue(response.isSuccess())
    }
    
    func test_service_deactivate_shouldBeSuccess() {
        // Only testeable in PRO
        let token = ""
        guard let response = try? bsanSubscriptionManager?.deactivate(token: token, instaID: "000000000000000049552916") else {
            return XCTFail("Fail to load get sign pattern")
        }
        XCTAssertTrue(response.isSuccess())
    }
}

