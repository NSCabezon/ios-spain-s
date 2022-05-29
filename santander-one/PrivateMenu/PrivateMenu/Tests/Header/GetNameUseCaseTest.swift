//
//  GetNameUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 4/5/22.
//

import CoreTestData
@testable import PrivateMenu
import XCTest

class GetNameUseCaseTest: XCTestCase {
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
    
    func test_Given_GlobalPositionLoaded_When_fetchNameOrAlias_Then_availableNameAndInitialsReturned() throws {
        let sut = DefaultGetNameUseCase(dependencies: dependencies)
        
        let name = try sut.fetchNameOrAlias().sinkAwait()
        XCTAssertNotNil(name)
        XCTAssertEqual(name.availableName, "PILAR RODRIGUEZ")
        XCTAssertEqual(name.initials, "PR")
    }
}
