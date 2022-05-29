//
//  GetFeaturedOptionsUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 3/5/22.
//

import CoreTestData
@testable import PrivateMenu
import XCTest

class GetFeaturedOptionsUseCaseTest: XCTestCase {
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
    
    func test_Given_noOptions_When_fetchFeaturedOptions_Then_noOptionsReturned() throws {
        let sut = DefaultGetFeaturedOptionsUseCase(dependencies: dependencies)
        
        let featuredOptions = try sut.fetchFeaturedOptions().sinkAwait()
        XCTAssertNotNil(featuredOptions)
        XCTAssertEqual(featuredOptions.count, 0)
    }
    
    func test_Given_featuredOptions_When_fetchFeaturedOptions_Then_featuredOptionsReturned() throws {
        let sut = GetFeaturedOptionsUseCaseSpy()
        
        let featuredOptions = try sut.fetchFeaturedOptions().sinkAwait()
        XCTAssertEqual(featuredOptions.count, 3)
    }
}
