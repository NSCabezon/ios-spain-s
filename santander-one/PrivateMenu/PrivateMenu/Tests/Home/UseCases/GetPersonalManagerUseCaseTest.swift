//
//  GetPersonalManagerUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreTestData
@testable import PrivateMenu
import XCTest

class GetPersonalManagerUseCaseTest: XCTestCase {
    func test_Given_GlobalPositionLoaded_When_fetchOptionsEnabledVisible_enabledOptionsReturned() throws {
        let sut = DefaultGetPersonalManagerUseCase()
        
        let personalManager = try sut.fetchPersonalManager().sinkAwait()
        XCTAssertNotNil(personalManager)
    }
}
