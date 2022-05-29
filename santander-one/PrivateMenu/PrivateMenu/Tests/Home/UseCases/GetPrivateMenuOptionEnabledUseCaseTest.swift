//
//  GetPrivateMenuOptionEnabledUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreTestData
@testable import PrivateMenu
import XCTest

class GetPrivateMenuOptionEnabledUseCaseTest: XCTestCase {
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
    
    func test_Given_GlobalPositionLoaded_When_fetchOptionsEnabledVisible_enabledOptionsReturned() throws {
        let sut = DefaultGetPrivateMenuOptionEnabledUseCase(dependencies: dependencies)
        
        let enabledOptions = try sut.fetchOptionsEnabledVisible().sinkAwait()
        XCTAssertNotNil(enabledOptions)
        XCTAssertEqual(enabledOptions.data.count, 13)
        XCTAssertEqual(enabledOptions.data[0].titleKey, "menu_link_tips")
        XCTAssertEqual(enabledOptions.data[3].featuredOptionsId, "marketplace")
        XCTAssertEqual(enabledOptions.data[5].iconKey, "icn_investment")
        XCTAssertEqual(enabledOptions.data[9].featuredOptionsId, "my_home")
    }
}
