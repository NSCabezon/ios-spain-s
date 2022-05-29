//
//  TimeLineDetailPresenterSpec.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by José Carlos Estela Anguita on 23/07/2019.


import Foundation
import Quick
import Nimble
import OHHTTPStubs
@testable import FinantialTimeline

class TimeLineDetailPresenterSpec: QuickSpec {
    
    var presenter: TimeLineDetailPresenter!
    var viewMock: TimeLineDetailViewMock!
    var interactor: TimeLineDetailInteractor!
    var ctaEngine = CTAEngine(locale: Locale(identifier: "es"))
    
    override func spec() {
        beforeEach {
            self.viewMock = TimeLineDetailViewMock()
            self.interactor = TimeLineDetailInteractor(timeLineRepository: TimeLineApiRepository(host: URL(string: "http://time_line_test/")!, restClient: IntelligentBankingRestClient(), authorization: .token("")))
        }
        afterEach {
            self.viewMock = nil
            self.presenter = nil
            self.interactor = nil
            OHHTTPStubs.removeAllStubs()
        }
        describe("test timeline detail") {
            describe("when view did load") {
                context("with an event with all data") {
                    beforeEach {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
                        TestHelpers.mockResponse(forPath: "/timeline/event/([A-Za-z0-9_])*", withFile: "event_detail.json")
                        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event", type: "json"))
                        self.presenter = TimeLineDetailPresenter(
                            view: self.viewMock,
                            interactor: self.interactor,
                            router: TimeLineDetailRouter(),
                            event: event,
                            textsEngine: TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es")),
                            ctaEngine: CTAEngine.getCTAEngine(for: [])
                        )
                        self.interactor.output = self.presenter
                        self.presenter.viewDidLoad()
                    }
                    it("should show all data") {
                        expect(self.viewMock.spyShowEventProductCalled) == true
                        expect(self.viewMock.spyShowAmountCalled) == true
                        expect(self.viewMock.spyShowEventLogoCalled) == true
                        expect(self.viewMock.spyShowEventNameCalled) == true
                        expect(self.viewMock.spyShowActivityCalled).toEventually(equal(true))
                        expect(self.viewMock.spyShowDescriptionCalled) == true
                        expect(self.viewMock.spyShowDate) == true
                        expect(self.viewMock.spyShowIssueDate) == true
                        expect(self.viewMock.spyShowDeferredDetails) == false
                        expect(self.viewMock.spyShowCTAs) == false
                    }
                }
                context("with an event without activity") {
                    beforeEach {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
                        TestHelpers.mockResponse(forPath: "/timeline/event/([A-Za-z0-9_])*", withFile: "event_detail_without_activity.json")
                        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_without_activity", type: "json"))
                        self.presenter = TimeLineDetailPresenter(
                            view: self.viewMock,
                            interactor: self.interactor,
                            router: TimeLineDetailRouter(),
                            event: event,
                            textsEngine: TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es")),
                            ctaEngine: CTAEngine.getCTAEngine(for: [])
                        )
                        self.interactor.output = self.presenter
                        self.presenter.viewDidLoad()
                    }
                    it("shouldn't show activity") {
                        expect(self.viewMock.spyShowEventProductCalled) == true
                        expect(self.viewMock.spyShowAmountCalled) == true
                        expect(self.viewMock.spyShowEventLogoCalled) == true
                        expect(self.viewMock.spyShowEventNameCalled) == true
                        expect(self.viewMock.spyShowActivityCalled).toEventually(equal(false))
                        expect(self.viewMock.spyShowDescriptionCalled) == true
                        expect(self.viewMock.spyShowDate) == true
                        expect(self.viewMock.spyShowIssueDate) == true
                        expect(self.viewMock.spyShowDeferredDetails) == false
                        expect(self.viewMock.spyShowCTAs) == false
                    }
                }
                context("with an event without amount") {
                    beforeEach {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
                        TestHelpers.mockResponse(forPath: "/timeline/event/([A-Za-z0-9_])*", withFile: "event_detail.json")
                        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_without_amount", type: "json"))
                        self.presenter = TimeLineDetailPresenter(
                            view: self.viewMock,
                            interactor: self.interactor,
                            router: TimeLineDetailRouter(),
                            event: event,
                            textsEngine: TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es")),
                            ctaEngine: CTAEngine.getCTAEngine(for: [])
                        )
                        self.interactor.output = self.presenter
                        self.presenter.viewDidLoad()
                    }
                    it("shouldn't show amount") {
                        expect(self.viewMock.spyShowEventProductCalled) == true
                        expect(self.viewMock.spyShowAmountCalled) == false
                        expect(self.viewMock.spyShowEventLogoCalled) == true
                        expect(self.viewMock.spyShowEventNameCalled) == true
                        expect(self.viewMock.spyShowActivityCalled).toEventually(equal(true))
                        expect(self.viewMock.spyShowDescriptionCalled) == true
                        expect(self.viewMock.spyShowDate) == true
                        expect(self.viewMock.spyShowIssueDate) == true
                        expect(self.viewMock.spyShowDeferredDetails) == false
                        expect(self.viewMock.spyShowCTAs) == false
                    }
                }
                context("with an event without product") {
                    beforeEach {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
                        TestHelpers.mockResponse(forPath: "/timeline/event/([A-Za-z0-9_])*", withFile: "event_detail.json")
                        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_without_product", type: "json"))
                        self.presenter = TimeLineDetailPresenter(
                            view: self.viewMock,
                            interactor: self.interactor,
                            router: TimeLineDetailRouter(),
                            event: event,
                            textsEngine: TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es")),
                            ctaEngine: CTAEngine.getCTAEngine(for: [])
                        )
                        self.interactor.output = self.presenter
                        self.presenter.viewDidLoad()
                    }
                    it("shouldn't show product") {
                        expect(self.viewMock.spyShowEventProductCalled) == false
                        expect(self.viewMock.spyShowAmountCalled) == true
                        expect(self.viewMock.spyShowEventLogoCalled) == true
                        expect(self.viewMock.spyShowEventNameCalled) == true
                        expect(self.viewMock.spyShowActivityCalled).toEventually(equal(true))
                        expect(self.viewMock.spyShowDescriptionCalled) == true
                        expect(self.viewMock.spyShowDate) == true
                        expect(self.viewMock.spyShowIssueDate) == true
                        expect(self.viewMock.spyShowDeferredDetails) == false
                        expect(self.viewMock.spyShowCTAs) == false
                    }
                }
                context("with an event with all data but just one activity") {
                    beforeEach {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
                        TestHelpers.mockResponse(forPath: "/timeline/event/([A-Za-z0-9_])*", withFile: "event_detail_with_one_activity.json")
                        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event", type: "json"))
                        self.presenter = TimeLineDetailPresenter(
                            view: self.viewMock,
                            interactor: self.interactor,
                            router: TimeLineDetailRouter(),
                            event: event,
                            textsEngine: TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es")),
                            ctaEngine: CTAEngine.getCTAEngine(for: [])
                        )
                        self.interactor.output = self.presenter
                        self.presenter.viewDidLoad()
                    }
                    it("shouldn't show activity") {
                        expect(self.viewMock.spyShowEventProductCalled) == true
                        expect(self.viewMock.spyShowAmountCalled) == true
                        expect(self.viewMock.spyShowEventLogoCalled) == true
                        expect(self.viewMock.spyShowEventNameCalled) == true
                        expect(self.viewMock.spyShowActivityCalled).toEventually(equal(false))
                        expect(self.viewMock.spyShowDescriptionCalled) == true
                        expect(self.viewMock.spyShowDate) == true
                        expect(self.viewMock.spyShowIssueDate) == true
                        expect(self.viewMock.spyShowDeferredDetails) == false
                        expect(self.viewMock.spyShowCTAs) == false
                    }
                }
                context("with an event without transaction.issueDate") {
                    beforeEach {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
                        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_without_transaction_issue_date", type: "json"))
                        TestHelpers.mockResponse(forPath: "/timeline/event/([A-Za-z0-9_])*", withFile: "event_detail.json")
                        self.presenter = TimeLineDetailPresenter(
                            view: self.viewMock,
                            interactor: self.interactor,
                            router: TimeLineDetailRouter(),
                            event: event,
                            textsEngine: TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es")),
                            ctaEngine: CTAEngine.getCTAEngine(for: [])
                        )
                        self.interactor.output = self.presenter
                        self.presenter.viewDidLoad()
                    }
                    it("shouldn't show issueDate") {
                        expect(self.viewMock.spyShowEventProductCalled) == true
                        expect(self.viewMock.spyShowAmountCalled) == true
                        expect(self.viewMock.spyShowEventLogoCalled) == true
                        expect(self.viewMock.spyShowEventNameCalled) == true
                        expect(self.viewMock.spyShowActivityCalled).toEventually(equal(true))
                        expect(self.viewMock.spyShowDescriptionCalled) == true
                        expect(self.viewMock.spyShowDate) == true
                        expect(self.viewMock.spyShowIssueDate) == false
                        expect(self.viewMock.spyShowDeferredDetails) == false
                        expect(self.viewMock.spyShowCTAs) == false
                    }
                }
                context("with an event with transaction.deferredDetails") {
                    beforeEach {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
                        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_with_deferred_data", type: "json"))
                        TestHelpers.mockResponse(forPath: "/timeline/event/([A-Za-z0-9_])*", withFile: "event_detail.json")
                        self.presenter = TimeLineDetailPresenter(
                            view: self.viewMock,
                            interactor: self.interactor,
                            router: TimeLineDetailRouter(),
                            event: event,
                            textsEngine: TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es")),
                            ctaEngine: CTAEngine.getCTAEngine(for: [])
                        )
                        self.interactor.output = self.presenter
                        self.presenter.viewDidLoad()
                    }
                    it("should show deferred details") {
                        expect(self.viewMock.spyShowEventProductCalled) == true
                        expect(self.viewMock.spyShowAmountCalled) == true
                        expect(self.viewMock.spyShowEventLogoCalled) == true
                        expect(self.viewMock.spyShowEventNameCalled) == true
                        expect(self.viewMock.spyShowActivityCalled).toEventually(equal(true))
                        expect(self.viewMock.spyShowDescriptionCalled) == true
                        expect(self.viewMock.spyShowDate) == true
                        expect(self.viewMock.spyShowIssueDate) == true
                        expect(self.viewMock.spyShowDeferredDetails) == true
                        expect(self.viewMock.spyShowCTAs) == false
                    }
                }
                context("with an event with transaction.deferredDetails and transaction.deferredDetails.schedulingDate undefined") {
                    beforeEach {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
                        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_with_deferred_data_no_scheduling", type: "json"))
                        TestHelpers.mockResponse(forPath: "/timeline/event/([A-Za-z0-9_])*", withFile: "event_detail.json")
                        self.presenter = TimeLineDetailPresenter(
                            view: self.viewMock,
                            interactor: self.interactor,
                            router: TimeLineDetailRouter(),
                            event: event,
                            textsEngine: TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es")),
                            ctaEngine: CTAEngine.getCTAEngine(for: [])
                        )
                        self.interactor.output = self.presenter
                        self.presenter.viewDidLoad()
                    }
                    it("should show deferred details without the schedule date") {
                        expect(self.viewMock.spyShowEventProductCalled) == true
                        expect(self.viewMock.spyShowAmountCalled) == true
                        expect(self.viewMock.spyShowEventLogoCalled) == true
                        expect(self.viewMock.spyShowEventNameCalled) == true
                        expect(self.viewMock.spyShowActivityCalled).toEventually(equal(true))
                        expect(self.viewMock.spyShowDescriptionCalled) == true
                        expect(self.viewMock.spyShowDate) == true
                        expect(self.viewMock.spyShowIssueDate) == true
                        expect(self.viewMock.spyShowDeferredDetails) == true
                        expect(self.viewMock.spyShowDeferredDetailsSchedule) == false
                        expect(self.viewMock.spyShowCTAs) == false
                    }
                }
                context("with an event with CTAs") {
                    beforeEach {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
                        TestHelpers.mockResponse(forPath: "/timeline/event/([A-Za-z0-9_])*", withFile: "event_with_cta.json")
                        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_with_cta", type: "json"))
                        self.presenter = TimeLineDetailPresenter(
                            view: self.viewMock,
                            interactor: self.interactor,
                            router: TimeLineDetailRouter(),
                            event: event,
                            textsEngine: TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es")),
                            ctaEngine: CTAEngine.getCTAEngine(for: ["001"])
                        )
                        self.interactor.output = self.presenter
                        self.presenter.viewDidLoad()
                    }
                    it("should show all data") {
                        expect(self.viewMock.spyShowEventProductCalled) == true
                        expect(self.viewMock.spyShowAmountCalled) == true
                        expect(self.viewMock.spyShowEventLogoCalled) == true
                        expect(self.viewMock.spyShowEventNameCalled) == true
                        expect(self.viewMock.spyShowActivityCalled).toEventually(equal(false))
                        expect(self.viewMock.spyShowDescriptionCalled) == true
                        expect(self.viewMock.spyShowDate) == true
                        expect(self.viewMock.spyShowIssueDate) == true
                        expect(self.viewMock.spyShowDeferredDetails) == true
                        expect(self.viewMock.spyShowCTAs) == false
                    }
                }
                context("with an event with CTAs in JSON but not in configuration") {
                    beforeEach {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom(TimeLineEvent.decode)
                        TestHelpers.mockResponse(forPath: "/timeline/event/([A-Za-z0-9_])*", withFile: "event_with_cta.json")
                        let event = try! decoder.decode(TimeLineEvent.self, from: TestHelpers.file(path: "event_with_cta", type: "json"))
                        self.presenter = TimeLineDetailPresenter(
                            view: self.viewMock,
                            interactor: self.interactor,
                            router: TimeLineDetailRouter(),
                            event: event,
                            textsEngine: TextsEngine(baseDate: Date(timeIntervalSince1970: 1551768159), locale: Locale(identifier: "es")),
                            ctaEngine: CTAEngine.getCTAEngine(for: ["002"])
                        )
                        self.interactor.output = self.presenter
                        self.presenter.viewDidLoad()
                    }
                    it("should show all data") {
                        expect(self.viewMock.spyShowEventProductCalled) == true
                        expect(self.viewMock.spyShowAmountCalled) == true
                        expect(self.viewMock.spyShowEventLogoCalled) == true
                        expect(self.viewMock.spyShowEventNameCalled) == true
                        expect(self.viewMock.spyShowActivityCalled).toEventually(equal(false))
                        expect(self.viewMock.spyShowDescriptionCalled) == true
                        expect(self.viewMock.spyShowDate) == true
                        expect(self.viewMock.spyShowIssueDate) == true
                        expect(self.viewMock.spyShowDeferredDetails) == true
                        expect(self.viewMock.spyShowCTAs) == false
                    }
                }
            }
        }
    }
}

extension CTAEngine {
    class func getCTAs() -> [String: CTAStructure] {
        let icon = Icon(URL: "", svg: "")
        let action = Action(type: "REMINDER", destinationURL: nil, delegateReference: nil, composedDescription: nil)
        return ["001": .init(name: ["es" : "Add reminder"], icon: icon, action: action, analyticsReference: "Testing")]
    }
    
    class func getCTAEngine(for ctaArray: [String]) -> CTAEngine {
        let engine = CTAEngine(locale: Locale(identifier: "es"))
        let text = TimeLineConfiguration.Text(
            transactionType: "101",
            transactionName: [:],
            disclaimer: [:],
            coming: [:],
            previous: [:],
            CTA: ctaArray,
            analyticsReference: "Testing"
        )
        engine.setupCTAs([text], CTAs: CTAEngine.getCTAs())
        return engine
    }
}
