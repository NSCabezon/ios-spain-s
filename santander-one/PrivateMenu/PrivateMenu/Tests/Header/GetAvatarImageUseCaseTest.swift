//
//  GetAvatarImageUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 3/5/22.
//

import CoreTestData
@testable import PrivateMenu
import UI
import UnitTestCommons
import XCTest

class GetAvatarImageUseCaseTest: XCTestCase {
    lazy var dependencies: TestPrivateMenuExternalDependencies = {
        return TestPrivateMenuExternalDependencies(injector: mockDataInjector)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobal"
        )
        return injector
    }()
    
    func test_GlobalPositionLoaded_When_FetchAvatarImage_Then_UserAvatarDataReturned() throws {
        let sut = DefaultGetAvatarImageUseCase(dependencies: dependencies)
        
        let data = try sut.fetchAvatarImage().sinkAwait()
        XCTAssertNotNil(data)
        XCTAssertEqual(data, Data("F15869".utf8))
    }
}
