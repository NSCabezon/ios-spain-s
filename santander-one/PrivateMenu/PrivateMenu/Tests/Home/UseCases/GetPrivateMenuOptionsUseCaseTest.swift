//
//  GetPrivateMenuOptionsUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

@testable import PrivateMenu
import XCTest

class GetPrivateMenuOptionsUseCaseTest: XCTestCase {
    func test_Given_GlobalPositionLoaded_When_fetchMenuOptions_menuOptionsReturned() throws {
        let sut = DefaultPrivateMenuOptionsUseCase()
        
        let menuOptions = try sut.fetchMenuOptions().sinkAwait()
        XCTAssertNotNil(menuOptions)
        XCTAssertEqual(menuOptions.count, 1)
        XCTAssertEqual(menuOptions[0].imageKey, "icnPgMenuRed")
        XCTAssertEqual(menuOptions[0].titleKey, "menu_link_pg")
        XCTAssertEqual(menuOptions[0].isHighlighted, true)
        XCTAssertEqual(menuOptions[0].type, .globalPosition)
    }
}
