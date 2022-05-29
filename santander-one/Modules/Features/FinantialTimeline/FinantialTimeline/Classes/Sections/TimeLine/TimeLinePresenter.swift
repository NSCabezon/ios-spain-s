//
//  TimeLinePresenter.swift
//  FinantialTimeline
//
//  Created by Antonio Muñoz Nieto on 02/07/2019.
//

import UIKit
import CoreFoundationLib

typealias TimeLineEventsPreviousAndComing = (previous: [TimeLineEvents], coming: [TimeLineEvents])

enum TimeLineEventsErrorType {
    
    case noEvents
    case error
    
    func logo() -> String {
        switch self {
        case .noEvents: return "icNoEventsError"
        case .error: return "icError"
        }
    }
}

class InitialTimeLineEventsHandler: TimeLineInteractorOutput {
    
    let comingPages: Int
    let previousPages: Int
    let interactor: TimeLineInteractorProtocol
    let date: Date
    
    private var completion: ((Result<TimeLineEventsPreviousAndComing, TimeLineEventsError>) -> Void)?
    private var comingTimeLineEvents: [TimeLineEvents] = []
    private var previousTimeLineEvents: [TimeLineEvents] = []
    private var comingTimeLineDidFail: Bool = false
    private var previousTimeLineDidFail: Bool = false
    
    struct TimeLineEventsError: Error {
        let title: String
        let error: Error
        let type: TimeLineEventsErrorType
    }
    
    init(date: Date, comingPages: Int, previousPages: Int, interactor: TimeLineInteractorProtocol) {
        self.date = date
        self.comingPages = comingPages
        self.previousPages = previousPages
        self.interactor = interactor
        self.interactor.output = self
    }
    
    func load(completion: @escaping (Result<TimeLineEventsPreviousAndComing, TimeLineEventsError>) -> Void) {
        self.completion = completion
        interactor.output = self
        if previousPages > 0 {
            interactor.loadPreviousTimeLine(date: date, offset: nil)
        }
        interactor.loadComingTimeLine(date: date, offset: nil)
    }
    
    func comingTimeLineDidFinishLoad(_ timeLine: TimeLineEvents) {
        TimeLine.dependencies.configuration?.currentDate = timeLine.currentDate
        comingTimeLineEvents.append(timeLine)
        guard comingTimeLineEvents.count < comingPages else { return comingTimeLineDidFinish() }
        guard timeLine.offset != nil else { return comingTimeLineDidFinishWithError(TimeLineError.unknown) }
        interactor.loadComingTimeLine(date: date, offset: timeLine.offset)
    }
    
    func previousTimeLineDidFinishLoad(_ timeLine: TimeLineEvents) {
        previousTimeLineEvents.append(timeLine)
        guard previousTimeLineEvents.count < previousPages else { return previousTimeLineDidFinish() }
        guard timeLine.offset != nil else { return previousTimeLineDidFinishWithError(TimeLineError.unknown) }
        interactor.loadPreviousTimeLine(date: date, offset: timeLine.offset)
    }
    
    func comingTimeLineDidFinishWithError(_ error: Error) {
        comingTimeLineDidFail = true
        comingTimeLineDidFinish()
    }
    
    func previousTimeLineDidFinishWithError(_ error: Error) {
        previousTimeLineDidFail = true
        previousTimeLineDidFinish()
    }
    
    private func comingTimeLineDidFinish() {
        guard isFinish() else { return }
        timeLineDidFinish()
    }
    
    private func previousTimeLineDidFinish() {
        guard isFinish() else { return }
        timeLineDidFinish()
    }
    
    private func isFinish() -> Bool {
        let comingTimeLineFinish = comingTimeLineEvents.count == comingPages || comingTimeLineDidFail
        let previousTimeLineFinish = previousTimeLineEvents.count == previousPages || previousTimeLineDidFail
        return comingTimeLineFinish && previousTimeLineFinish
    }
    
    private func timeLineDidFinish() {
        let result: Result<TimeLineEventsPreviousAndComing, TimeLineEventsError>
        defer {
            completion?(result)
        }
        guard !comingTimeLineDidFail || !previousTimeLineDidFail else {
            result = .failure(TimeLineEventsError(title: GeneralString().errorTitle, error: TimeLineError.unknown, type: .error))
            return
        }
        guard comingTimeLineEvents.allEvents().count == 0 && previousTimeLineEvents.allEvents().count == 0 else {
            result = .success((previous: previousTimeLineEvents, coming: comingTimeLineEvents))
            return
        }
        result = .failure(TimeLineEventsError(title: GeneralString().emptyState, error: TimeLineError.noEvents, type: .noEvents))
    }
}

final class TimeLinePresenter {
    
    weak private var view: TimeLineViewProtocol?
    private let interactor: TimeLineInteractorProtocol
    private let router: TimeLineWireframeProtocol
    private var comingTimeLineEvents: [TimeLineEvents] = []
    private var previousTimeLineEvents: [TimeLineEvents] = []
    private var initialTimeLineEventsHandler: InitialTimeLineEventsHandler?
    internal var isLoadMoreComingEventsAvailable: Bool = false
    internal var isLoadMorePreviousEventsAvailable: Bool = false
    private lazy var timeLineBuilder = {
        TimeLineBuilder(strategy: self.view?.strategy)
    }()
    private var selectedDate: Date = TimeLine.dependencies.configuration?.currentDate ?? Date() {
        didSet {
            loadTimeLine()
        }
    }
    private let textsEngine: TextsEngine
    private let configurationEngine: ConfigurationEngine
    private let dependenciesResolver: DependenciesResolver
    private var firstLoad = true
    private var serviceDate: Date?
    
    init(interface: TimeLineViewProtocol, interactor: TimeLineInteractorProtocol, router: TimeLineWireframeProtocol, configurationEngine: ConfigurationEngine, textsEngine: TextsEngine, dependenciesResolver: DependenciesResolver) {
        self.view = interface
        self.interactor = interactor
        self.router = router
        self.configurationEngine = configurationEngine
        self.textsEngine = textsEngine
        self.dependenciesResolver = dependenciesResolver
    }
}

extension TimeLinePresenter: TimeLinePresenterProtocol {
    func viewDidLoad() {
        interactor.getDate { [weak self] date in
            guard let self = self else { return }
            self.serviceDate = date
            TimeLine.dependencies.configuration?.currentDate = date
            self.loadTimeLine()
//            self.view?.showMenuOptions([
//                MenuItem(title: MenuTitle().createEvent, logo: "icCreateEvent", action: self.loadCustomEvent),
//                        MenuItem(title: MenuTitle().setup, logo: "icSetup", action: self.goToSettings),
//            //            MenuItem(title: IBLocalizedString("menu.personal.events"), logo: "icPersonalEvents", action: {}),
//            //            MenuItem(title: MenuTitle().export, logo: "icExport", action: exportEventsToCalendar)
//            //            MenuItem(title: IBLocalizedString("menu.help"), logo: "icHelp", action: {})
//                        MenuItem(title: MenuTitle().personalEvents, logo: "icPersonalEvents", action: self.loadCustomEvents)
//                    ])
            let today = TimeLine.dependencies.configuration?.currentDate ?? Date()
            let months = [
                today.adding(.month, value: -3).startOfMonth(),
                today.adding(.month, value: -2).startOfMonth(),
                today.adding(.month, value: -1).startOfMonth(),
                today.startOfMonth(),
                today.adding(.month, value: 1).startOfMonth(),
                today.adding(.month, value: 2).startOfMonth()
            ]
            self.view?.showMonthSelector(months: months)
        }
        trackScreen()
    }
    
    func loadTimeLine() {
        timeLineBuilder.reset()
        comingTimeLineEvents = []
        previousTimeLineEvents = []
        view?.showLoadingIndicator()
        configurationEngine.load(delegate: self)
    }
    
    func loadCustomEvent() {           
        router.loadNewCustomEvent()
    }
    
    func exportEventsToCalendar() {
        router.exportEventsToCalendar()
    }
    
    func goToSettings() {
        router.goToSettings(with: self)
    }
    
    func loadCustomEvents() {
        router.loadCustomEvents()
    }
    
    func loadMoreComingTimeLineEvents() {
        guard let offset = comingTimeLineEvents.last?.offset, isLoadMoreComingEventsAvailable else { return }
        isLoadMoreComingEventsAvailable = false
        interactor.loadComingTimeLine(date: selectedDate, offset: offset)
    }
    
    func loadMorePreviousTimeLineEvents() {
        guard let offset = previousTimeLineEvents.last?.offset, isLoadMorePreviousEventsAvailable else { return }
        isLoadMorePreviousEventsAvailable = false
        interactor.loadPreviousTimeLine(date: selectedDate, offset: offset)
    }
    
    func didSelectMonth(_ month: Date) {
        selectedDate = month
    }
    
    func didSelectTimeLineEvent(_ event: TimeLineEvent) {
        router.loadTimeLineEventDetail(event)
        trackEvent(.openDetail, parameters: [:])
    }
    
    func didSelectBack() {
        router.dismiss()
    }
    
    func setFirstLoad() {
        firstLoad = false
    }
    
    func trackLink(with url: URL) {
        var parameters: [TrackerDimension : String] = [:]
        var parameter = url.absoluteString
        let ranges = parameter.ranges(of: "santanderRetail://deeplink?n=")
        if ranges.count > 0 {
            parameter.removeSubrange(ranges[0])
            parameters[.deeplinkLogin] = parameter
        } else {
            parameters[.link] = parameter
        }
        trackEvent(.link, parameters: parameters)
    }
}

extension TimeLinePresenter: TimeLineInteractorOutput {
    
    func setComingError() {
        
    }
    
    func comingTimeLineDidFinishLoad(_ timeLine: TimeLineEvents) {
        if let mappedResult = view?.strategy?.mapComingResult(timeLine) {
            comingTimeLineEvents.append(mappedResult)
            comingTimeLineDidMapped(mappedResult)
        } else {
            comingTimeLineEvents.append(timeLine)
            comingTimeLineDidMapped(timeLine)
        }  
    }
    
    func comingTimeLineDidMapped(_ timeLine: TimeLineEvents) {
        let timeLineGroupedByDate = timeLine.events.reduce([:], groupTimeLineByDate)
        timeLineBuilder.addComingItems(timeLineGroupedByDate)
        if timeLine.offset == nil, view?.strategy?.shouldPresentFooter() ?? false {
            timeLineBuilder.setComingError(TimeLineError.noMoreComingEvents)
        }
        view?.comingTimeLineLoaded(withSections: timeLineBuilder.build())
    }
    
    func previousTimeLineDidFinishLoad(_ timeLine: TimeLineEvents) {
        if let isList = view?.strategy?.isList(), isList {
            previousTimeLineEvents.append(timeLine)
            let timeLineGroupedByDate = timeLine.events.reduce([:], groupTimeLineByDate)
            timeLineBuilder.addPreviousItems(timeLineGroupedByDate)
            if timeLine.offset == nil {
                timeLineBuilder.setPreviousError(TimeLineError.noMorePreviousEvents)
            }
            view?.previousTimeLineLoaded(withSections: timeLineBuilder.build())
        } else {
        }
    }
    
    func comingTimeLineDidFinishWithError(_ error: Error) {
        isLoadMoreComingEventsAvailable = false
        timeLineBuilder.setComingError(error)
        view?.comingTimeLineLoaded(withSections: timeLineBuilder.build())
    }
    
    func previousTimeLineDidFinishWithError(_ error: Error) {
        isLoadMorePreviousEventsAvailable = false
        timeLineBuilder.setPreviousError(error)
        view?.previousTimeLineLoaded(withSections: timeLineBuilder.build())
    }
    
    func timeLineLoaded() {
        isLoadMorePreviousEventsAvailable = previousTimeLineEvents.last?.offset != nil
        isLoadMoreComingEventsAvailable = comingTimeLineEvents.last?.offset != nil
    }
}

extension TimeLinePresenter: ConfigurationEngineDelegate {
    
    func configurationDidFinishLoad(_ configuration: TimeLineConfiguration) {
        isLoadMorePreviousEventsAvailable = false
        isLoadMoreComingEventsAvailable = false
        if firstLoad {
            initialTimeLineEventsHandler = InitialTimeLineEventsHandler(date: serviceDate ?? selectedDate,
                                                                        comingPages: configuration.timelineProperties.comingEventsPages,
                                                                        previousPages: configuration.timelineProperties.previousEventsPages,
                                                                        interactor: interactor)
        } else {
            initialTimeLineEventsHandler = InitialTimeLineEventsHandler(date: selectedDate,
                                                                        comingPages: configuration.timelineProperties.comingEventsPages,
                                                                        previousPages: configuration.timelineProperties.previousEventsPages,
                                                                        interactor: interactor)
        }

        initialTimeLineEventsHandler?.load { [weak self] result in
            defer {
                self?.interactor.output = self
            }
            switch result {
            case .success((let previous, let coming)):
                self?.handleInitialComingResult(coming)
                if configuration.timelineProperties.previousEventsPages > 0 {
                    self?.handleInitialPreviousResult(previous)
                } else {
                    self?.isLoadMorePreviousEventsAvailable = false
                }
                guard let all = self?.timeLineBuilder.build().allEventsByDate() else { return }
                if let self = self, let firstComingEvent = all.first(where: self.isSameDateOrIsHigherThanSelectedDate)?.firstTimeLineEvent() {
                    self.view?.move(to: firstComingEvent)
                } else if let last = all.last?.firstTimeLineEvent() {
                    self?.view?.move(to: last)
                }
                
                if let firstLoad = self?.firstLoad,
                    firstLoad {
                    self?.view?.scrollToToday()
                }
            case .failure(let error):
                self?.view?.timeLineDidFail(title: error.title, error: error.error, type: error.type)
            }
        }
    }
    
    func configurationDidFinishWithError(_ error: Error) {
        view?.timeLineDidFail(title: GeneralString().errorTitle, error: error, type: .error)
    }
}

private extension TimeLinePresenter {
    
    /// Returns a dictionary of dates (in the same day) and an array of events that day
    func groupTimeLineByDate(_ groupedTimeLineEvent: [Date: [TimeLineEvent]], event: TimeLineEvent) -> [Date: [TimeLineEvent]] {
        var groupedTimeLineEvent = groupedTimeLineEvent
        guard
            let dateByDay = groupedTimeLineEvent.keys.first(where: { $0.isSameDay(than: event.date) }),
            let timeLineEventsByDate = groupedTimeLineEvent[dateByDay]
        else {
            groupedTimeLineEvent[event.date.startOfDay()] = [event]
            return groupedTimeLineEvent
        }
         groupedTimeLineEvent[dateByDay] = timeLineEventsByDate + [event]
        return groupedTimeLineEvent
    }
    
    func isSameDateOrIsHigherThanSelectedDate(_ timeLineSection: TimeLineSection) -> Bool {
        guard let date = timeLineSection.date() else { return false }
        return date.isSameDay(than: self.selectedDate) || date > self.selectedDate
    }
    
    func loadPreviousTimeLine(offset: String? = nil) {
        interactor.loadPreviousTimeLine(date: selectedDate, offset: offset)
    }
    
    func loadComingTimeLine(offset: String? = nil) {
        interactor.loadComingTimeLine(date: selectedDate, offset: offset)
    }
    
    func handleInitialPreviousResult(_ previous: [TimeLineEvents]) {
        if previous.count > 0 {
            previous.forEach(previousTimeLineDidFinishLoad)
            if previous.count != initialTimeLineEventsHandler?.previousPages {
                previousTimeLineDidFinishWithError(TimeLineError.noMorePreviousEvents)
            }
        } else {
            previousTimeLineDidFinishWithError(TimeLineError.noMorePreviousEvents)
        }
    }
    
    func handleInitialComingResult(_ coming: [TimeLineEvents]) {
        if coming.count > 0 {
            coming.forEach(comingTimeLineDidFinishLoad)
            if coming.count != initialTimeLineEventsHandler?.comingPages, view?.strategy?.shouldPresentFooter() ?? false {
                comingTimeLineDidFinishWithError(TimeLineError.noMoreComingEvents)
            }
        } else if view?.strategy?.shouldPresentFooter() ?? false {
            self.comingTimeLineDidFinishWithError(TimeLineError.noMoreComingEvents)
        }
    }
}

extension TimeLinePresenter: TimeLineDetailDelegate {
    func didTappedBack() {        
        loadTimeLine()        
    }
    
    func deleteEventSucceed() {
        view?.showAlert(message: CustomEventDetailString().deleteEventSucceedAlertMessage)
    }
}

extension TimeLinePresenter: NewCustomEventDelegate {
    func eventUpdated() {
        loadTimeLine()
        view?.showAlert(message: TimeLineDetailString().eventModified)        
    }
}

extension TimeLinePresenter: AutomaticScreenActionTrackable {
    var trackerPage: TimeLinePage {
        return TimeLinePage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
