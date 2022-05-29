//
//  GetSanflixUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreTestData
@testable import PrivateMenu
import XCTest

class GetSanflixUseCaseTest: XCTestCase {
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
    
    func test_When_fetchSanflix_sanflixContractReturned() throws {
        let sut = DefaultGetSanflixUseCase(dependencies: dependencies)
        
        let sanflixContract = try sut.fetchSanflix().sinkAwait()
        XCTAssertNotNil(sanflixContract)
        XCTAssertEqual(sanflixContract.isSanflixEnabled, false)
        XCTAssertEqual(sanflixContract.isEnabledExploreProductsInMenu, false)
    }
}
