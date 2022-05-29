//
//  BiometryValidatorPresenterTest.swift
//  BiometryValidator_Example
//
//  Created by Rubén Márquez Fernández on 26/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetupES
import UnitTestCommons
import SANLibraryV3
import CoreFoundationLib
@testable import BiometryValidator

class BiometryValidatorPresenterTest: XCTestCase {
    
    override func setUp() {
        QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo).doLogin(withUser: .demo)
    }
    override func tearDown() {
    }
    
    func test_viewDidLoad() {
    }
}
