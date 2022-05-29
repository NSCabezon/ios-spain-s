//
//  GetPrivateMenuFooterOptionsUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreTestData
@testable import PrivateMenu
import XCTest

class GetPrivateMenuFooterOptionsUseCaseTest: XCTestCase {
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
    
    func test_When_fetchFooterOptions_footerOptionsReturned() throws {
        let sut = DefaultMenuFooterOptionsUseCase()
        
        let footerOptions = try sut.fetchFooterOptions().sinkAwait()
        XCTAssertNotNil(footerOptions)
        XCTAssertEqual(footerOptions.count, 1)
        XCTAssertEqual(footerOptions[0].title, "menu_link_HelpCenter")
        XCTAssertEqual(footerOptions[0].optionType, .helpCenter)
    }
}
