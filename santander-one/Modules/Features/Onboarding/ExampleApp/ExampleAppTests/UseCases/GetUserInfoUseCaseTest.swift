//
//  GetUserInfoUseCaseTests.swift
//  ExampleAppTests
//
//  Created by Jose Ignacio de Juan Díaz on 31/12/21.
//


import Foundation
import XCTest
import OpenCombine
import CoreTestData
import CoreDomain
import UnitTestCommons
import QuickSetup
@testable import Onboarding


class GetUserInfoUseCaseTest: XCTestCase {
    let external = TestOnboardingExternalDependencies()
    lazy var sut: DefaultGetUserInfoUseCase = {
        return DefaultGetUserInfoUseCase(dependencies: external)
    }()
    
    func test_fetch() throws {
        let userInfo = try sut.fetch().sinkAwait()
        XCTAssertEqual("12345678", userInfo.id)
        XCTAssertEqual("MyAlias", userInfo.alias)
        XCTAssertEqual("Little Alice", userInfo.name)
        XCTAssertEqual(GlobalPositionOptionEntity.classic, userInfo.globalPosition)
        XCTAssertEqual(0, userInfo.photoTheme)
        XCTAssertEqual(PGColorMode.red, userInfo.pgColorMode)
    }
}
