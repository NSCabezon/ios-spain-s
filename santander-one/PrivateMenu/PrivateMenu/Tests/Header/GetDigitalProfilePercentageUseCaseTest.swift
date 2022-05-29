//
//  GetDigitalProfilePercentageUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 3/5/22.
//

import CoreTestData
@testable import PrivateMenu
import XCTest

class GetDigitalProfilePercentageUseCaseTest: XCTestCase {
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
    
    func test_When_fetchDigitalProfilePercentage_Then_returnsPercentageDouble() throws {
        let sut = DefaultGetDigitalProfilePercentageUseCase(dependencies: dependencies)
        
        let percentage = try sut.fetchDigitalProfilePercentage().sinkAwait()
        XCTAssertEqual(percentage, 45)
    }
    
    func test_When_fetchIsDigitalProfileEnabled_Then_returnsFalse() throws {
        let sut = DefaultGetDigitalProfilePercentageUseCase(dependencies: dependencies)
        
        let isEnabled = try sut.fetchIsDigitalProfileEnabled().sinkAwait()
        XCTAssertEqual(isEnabled, false)
    }
}
