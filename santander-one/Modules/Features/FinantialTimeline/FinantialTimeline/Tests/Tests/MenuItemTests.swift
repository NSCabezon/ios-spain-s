//
//  MenuItemTests.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 16/09/2019.
//

import XCTest
@testable import FinantialTimeline

class MenuItemTests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        
    }

    func testMenuItem() {
        // G
        let title = "Título"
        let logo = "Logo"
        let action: () -> Void = {print("Acción")}
        
        // W
        let menuItem = MenuItem(title: title, logo: logo, action: action)
        
        // T
        XCTAssertEqual(menuItem.title, title)
        XCTAssertEqual(menuItem.logo, logo)
        
    }

}
