//
//  GetMarketplaceWebViewConfigurationUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 4/5/22.
//

import CoreTestData
@testable import PrivateMenu
import XCTest

class GetMyProductsUseCaseTest: XCTestCase {
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
    
    func test_Given_GlobalPositionLoaded_When_fetchMyProducts_Then_myProductsReturned() throws {
        let sut = DefaultGetMyProductsUseCase(dependencies: dependencies)
        
        let myProducts = try sut.fetchMyProducts().sinkAwait()
        XCTAssertNotNil(myProducts)
    }
}
