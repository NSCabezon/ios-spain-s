//
//  TimeLineViewControllerTests.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by José Carlos Estela Anguita on 02/08/2019.
//
import XCTest
import Nimble
import OHHTTPStubs
@testable import FinantialTimeline

class TimeLineViewControllerTests: XCTestCase {
    
    var viewController: TimeLineViewController!
    var presenterMock: TimeLinePresenterMock!
    var uiHelpers: UIHelpers<TimeLineViewController>!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        uiHelpers = UIHelpers<TimeLineViewController>()
        presenterMock = TimeLinePresenterMock(isLoadMoreComingEventsAvailable: false, isLoadMorePreviousEventsAvailable: false)
        viewController = TimeLineViewController.fromStoryBoard()
        viewController.presenter = presenterMock
        uiHelpers.setup(withViewController: viewController)
    }

    override func tearDown() {
        viewController = nil
        presenterMock = nil
        uiHelpers.tearDown()
        super.tearDown()
    }
    
    func test_timeLineViewController_loadCorrectly() {
        expect(self.presenterMock.spyViewDidLoadCalled) == true
    }
    
    //TODO: Move tests to strategy tests
//    func test_timeLineViewController_shouldNotify_onceItLoadsAllData() {
//        // G
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
//        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event", type: "json"))
//        let timeLineSection = TimeLineSection.eventsByDate(date: TimeLine.dependencies.configuration?.currentDate ?? Date(), timeLineEvent: [event])
//        // W
//        viewController.comingTimeLineLoaded(withSections: [timeLineSection])
//        // T
//        expect(self.presenterMock.spyTimeLineLoadedCalled).toEventually(equal(true))
//    }
//
//    func test_timeLineViewController_shouldShowError_whenAnErrorHappend() {
//        // G
//        // W
//        viewController.timeLineDidFail(title: "Error", error: TimeLineError.noEvents, type: .error)
//        // T
//        expect(self.viewController.errorView.isHidden).toEventually(equal(false))
//        expect(self.viewController.titleErrorLabel.text).toEventually(equal("Error"))
//        expect(self.viewController.errorLabel.text).toEventually(equal("We still don't have movements to display in your Time-Line; Make sure that filters are not active"))
//    }
}
