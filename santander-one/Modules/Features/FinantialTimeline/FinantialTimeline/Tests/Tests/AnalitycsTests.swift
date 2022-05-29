//
//  AnalitycsTests.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Hernán Villamil on 10/10/2019.
//

import Foundation
import XCTest
@testable import FinantialTimeline

class AnalitycsTests: XCTestCase {
    var sut: String!
    
    override func setUp() {
        super.setUp()
        sut = "testing"
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_track_event() {
        AnalyticsHelper.trackEvent(.init(screen: "test", eventName: "test", category: "testing"))
    }
    
    func test_track_screen() {
        AnalyticsHelper.trackScreen(.init(screen: "test"))
    }
    
    func test_event() {
        let event = AnalyticsItem(screen: "test", eventName: "test", category: "testing", action: "testing")
        let data = event.data
        XCTAssertEqual(data["EventCategory"] as? String, "testing")
        XCTAssertEqual(data["EventAction"] as? String, "testing")
    }
    
    func test_screen() {
        let screen = AnalyticsItem(screen: "test")
        let data = screen.data
        XCTAssertEqual(data["Component"] as? String, AnalyticsSetting.componentName)
        XCTAssertEqual(data["AppVersion"] as? String, Utils.getAppVersion())
        XCTAssertEqual(data["AppName"] as? String, Utils.getAppName())
        XCTAssertEqual(data["ScreenName"] as? String, "intbank financial timeline:test")
        XCTAssertEqual(data["AppType"] as? String, "retail")
    }

}
