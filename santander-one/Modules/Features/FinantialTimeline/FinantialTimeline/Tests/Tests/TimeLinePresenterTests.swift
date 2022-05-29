//
//  TimeLinePresenterTests.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by José Carlos Estela Anguita on 05/07/2019.
//
import XCTest
import Nimble
import OHHTTPStubs
import CacheLib
@testable import FinantialTimeline

class TimeLinePresenterTests: XCTestCase {
    
    // MARK: - Attributes
    
    var presenter: TimeLinePresenter!
    var mockView: TimeLineViewMock!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        TestHelpers.mockResponse(forPath: "/timeline/configuration", withFile: "configuration.json")
        mockView = TimeLineViewMock()
        let interactor = TimeLineInteractor(timeLineRepository: TimeLineApiRepository(host: URL(string: "http://time_line_test/")!, restClient: IntelligentBankingRestClient(), authorization: .token("")))
        let textsEngine = TextsEngine(baseDate: TimeLine.dependencies.configuration?.currentDate ?? Date(), locale: .current)
        let ctaEngine = CTAEngine( locale: .current)
        presenter = TimeLinePresenter(
            interface: mockView,
            interactor: interactor,
            router: TimeLineRouter(),
            configurationEngine: ConfigurationEngine(
                configurationRepository: ConfigurationApiRepository(
                    remoteDataSource: ConfigurationRemoteDataSource(
                        url: URL(string: "http://time_line_test/timeline/configuration")!,
                        restClient: IntelligentBankingRestClient(),
                        authorization: .token("")
                    ),
                    cacheDataSource: ConfigurationCacheDataSource()
                ),
                textsEngine: textsEngine,
                ctasEngine: ctaEngine
            ), textsEngine: textsEngine
        )
    }
    
    override func tearDown() {
        presenter = nil
        mockView = nil
        try! CacheLib.shared.clearCache()
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    // MARK: - Test
    
    func test_timeLine_shouldGroupTimeLineEventsInTheSameDay() {
        // G
        TestHelpers.mockResponse(forPath: "/([0-9+])*/previous", withFile: "previous_timeline_events.json")
        TestHelpers.mockResponse(forPath: "/([0-9+])*/coming", withFile: "coming_timeline_events.json")
        // T
        presenter.loadTimeLine()
        // W
        var dates: [Date] { // Computed property because the task is async
            return mockView.spyTimeLineSections.allDates()
        }
        expect(dates.count).toEventually(equal(2))
        expect(dates).toEventually(containElementSatisfying({ $0.isSameDay(than: TestHelpers.date(from: "2020-03-09", format: "yyyy-MM-dd")) }))
        expect(dates).toEventually(containElementSatisfying({ $0.isSameDay(than: TestHelpers.date(from: "2020-03-16", format: "yyyy-MM-dd")) }))
    }
    
    func test_timeLine_shouldShowTimeLineEvents() {
        // G
        TestHelpers.mockResponse(forPath: "/([0-9+])*/previous/([0-9])*", withFile: "previous_timeline_events.json")
        TestHelpers.mockResponse(forPath: "/([0-9+])*/coming/([0-9])*", withFile: "coming_timeline_events.json")
        // T
        presenter.loadTimeLine()
        // W
        expect(self.mockView.spyTimeLineSections).toEventuallyNot(beEmpty())
    }
    
    func test_timeLine_shouldShowErrorIfPreviousAndComingEventsFailed() {
        // G
        TestHelpers.mockResponse(forPath: "/([0-9+])*/previous/([0-9])*", withFile: "empty.json", statusCode: 500)
        TestHelpers.mockResponse(forPath: "/([0-9+])*/coming/([0-9])*", withFile: "empty.json", statusCode: 500)
        // T
        presenter.loadTimeLine()
        // W
        expect(self.mockView.spyTimeLineError).toEventuallyNot(beNil())
    }
    
    func test_timeLine_whenWantsToLoadMoreComingTimeLineEvents_shouldLoadMoreComingEvents() {
//        // G
//        TestHelpers.mockResponse(forPath: "/([0-9+])*/coming/([0-9])*", withFile: "coming_timeline_events.json")
//        presenter.loadTimeLine()
//
//        // T
//        wait(for: 1.0) // in order to wait to loadtimeline finish
//        presenter.timeLineLoaded()
//        OHHTTPStubs.removeAllStubs()
//        TestHelpers.mockResponse(forPath: "/([0-9+])*/coming/20", withFile: "timeline_events_second_page.json")
//        self.presenter.loadMoreComingTimeLineEvents()
//        // W
//        expect(self.mockView.spyTimeLineSections).toEventually(containElementSatisfying({ $0.find(by: \.identifier, value: "idSecondPageFirstItem") != nil }))
    }
    
//    func test_timeLine_whenWantsToLoadMorePreviousTimeLineEvents_shouldLoadMorePreviousEvents() {
//        // G
//        TestHelpers.mockResponse(forPath: "/([0-9+])*/previous/([0-9])*", withFile: "previous_timeline_events.json")
//        presenter.loadTimeLine()
//        // T
//        wait(for: 1.0) // in order to wait to loadtimeline finish
//        presenter.timeLineLoaded()
//        OHHTTPStubs.removeAllStubs()
//        TestHelpers.mockResponse(forPath: "/([0-9+])*/previous/20", withFile: "timeline_events_second_page.json")
//        presenter.loadMorePreviousTimeLineEvents()
//        // W
//        expect(self.mockView.spyTimeLineSections).toEventually(containElementSatisfying({ $0.find(by: \.identifier, value: "idSecondPageFirstItem") != nil }))
//    }
    
    func test_timeLine_whenPreviousTimeLineEventsAre0InConfiguration_shouldNotAllowToRequestPreviousEvents() {
        // G
        TestHelpers.mockResponse(forPath: "/timeline/configuration", withFile: "configuration_without_previous.json")
        TestHelpers.mockResponse(forPath: "/([0-9+])*/coming/([0-9])*", withFile: "coming_timeline_events.json")
        TestHelpers.mockResponse(forPath: "/([0-9+])*/previous/([0-9])*", withFile: "previous_timeline_events.json")
        // T
        presenter.loadTimeLine()
        // W
        expect(self.presenter.isLoadMorePreviousEventsAvailable).toEventually(equal(false))
    }
}
