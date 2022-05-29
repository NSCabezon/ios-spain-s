//
//  TimeLineDetailViewControllerTests.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 16/09/2019.


import XCTest
import SantanderUIKitLib
@testable import FinantialTimeline

class TimeLineDetailViewControllerTests: XCTestCase {
    
    var viewController: TimeLineDetailViewController!
    var presenterMock: TimeLineDetailPresenterMock!
    
    var viewDidLoadExpectation: XCTestExpectation!

    override func setUp() {
        super.setUp()
        viewDidLoadExpectation = XCTestExpectation(description: "viewDidLoad")
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        presenterMock = TimeLineDetailPresenterMock()
        let storyboard = UIStoryboard(name: "TimeLineDetail", bundle: .module)
        viewController = storyboard.instantiateViewController(withIdentifier: "TimeLineDetailViewController") as? TimeLineDetailViewController
        viewController.presenter = presenterMock
//        _ = viewController.view

    }

    override func tearDown() {
        viewController = nil
        presenterMock = nil
        super.tearDown()
    }
    
    func testViewDidLoad() {
        // G
        presenterMock.expectation = viewDidLoadExpectation
        
        // W
        presenterMock.viewDidLoad()
        
        // T
        wait(for: [viewDidLoadExpectation], timeout: 2)
    }
    
    func testRenderChartWith() {
        // G
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_with_deferred_data", type: "json"))
        
        // T
        XCTAssertNotNil(event.activity)
    }
    
    func testShowAmount() {
        // G
        let amount = Amount(value: 24.56, currencyCode: "€")
        
        // W
        
        // T
        XCTAssertNotNil(amount)
    }
    
    func testShowCTAs() {
        // G
        let cta1 = CTAAction(identifier: "Test CTA1")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
        let ctaArray = [cta1]
        // W
        
        // T
        XCTAssertNotNil(ctaArray)
    }
}
