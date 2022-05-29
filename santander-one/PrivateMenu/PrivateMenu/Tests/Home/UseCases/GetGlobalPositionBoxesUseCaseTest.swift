//
//  GetGlobalPositionBoxesUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 4/5/22.
//

import CoreTestData
@testable import PrivateMenu
import XCTest

class GetGlobalPositionBoxesUseCaseTest: XCTestCase {
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
    
    func test_GlobalPositionLoaded_When_fetchBoxesVisibles_Then_returnsVisibleBoxes() throws {
        let sut = DefaultGlobalPositionBoxesUseCase(dependencies: dependencies)
        
        let userPrefBoxType = try sut.fetchBoxesVisibles().sinkAwait()
        XCTAssertNotNil(userPrefBoxType)
    }
}
