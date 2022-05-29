//
//  GetPrivateMenuConfigUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 4/5/22.
//

import CoreTestData
@testable import PrivateMenu
import XCTest

class GetPrivateMenuConfigUseCaseTest: XCTestCase {
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
    
    func test_Given_GlobalPositionLoaded_When_fetchPrivateConfigMenuData_Then_privateMenuConfigReturned() throws {
        let sut = DefaultGetPrivateMenuConfigUseCase(dependencies: dependencies)
        
        let privateMenuConfig = try sut.fetchPrivateConfigMenuData().sinkAwait()
        XCTAssertNotNil(privateMenuConfig)
        XCTAssertEqual(privateMenuConfig.isMarketplaceEnabled, false)
        XCTAssertEqual(privateMenuConfig.isEnabledBillsAndTaxesInMenu, false)
        XCTAssertEqual(privateMenuConfig.isVirtualAssistantEnabled, false)
    }
}
