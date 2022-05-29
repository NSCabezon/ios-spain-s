//
//  TimeLineProtocols.swift
//  FinantialTimeline
//
//  Created by Antonio Muñoz Nieto on 02/07/2019.
//

import Foundation

// MARK: Wireframe -
protocol TimeLineWireframeProtocol: AnyObject {
    func loadTimeLineEventDetail(_ event: TimeLineEvent)
    func loadNewCustomEvent()
    func exportEventsToCalendar()
    func goToSettings(with delegate: TimeLineDetailDelegate)
    func loadCustomEvents()
    func dismiss()
}
// MARK: Presenter -
protocol TimeLinePresenterProtocol: AnyObject {
    var isLoadMoreComingEventsAvailable: Bool { get set }
    var isLoadMorePreviousEventsAvailable: Bool { get set }
    func loadTimeLine()
    func loadMoreComingTimeLineEvents()
    func loadMorePreviousTimeLineEvents()
    func didSelectMonth(_ month: Date)
    func viewDidLoad()
    func didSelectTimeLineEvent(_ event: TimeLineEvent)
    func didSelectBack()
    func timeLineLoaded()
    func exportEventsToCalendar()
    func goToSettings()
    func setFirstLoad()
    func trackLink(with url: URL)
}

protocol TimeLineInteractorOutput: AnyObject {
    func comingTimeLineDidFinishLoad(_ timeLine: TimeLineEvents)
    func previousTimeLineDidFinishLoad(_ timeLine: TimeLineEvents)
    func comingTimeLineDidFinishWithError(_ error: Error)
    func previousTimeLineDidFinishWithError(_ error: Error)
}

// MARK: Interactor -
protocol TimeLineInteractorProtocol: AnyObject {
    var output: TimeLineInteractorOutput? { get set }    
    func loadComingTimeLine(date: Date, offset: String?)
    func loadPreviousTimeLine(date: Date, offset: String?)
    func getDate(completion: @escaping(Date?) -> Void)
}
// MARK: View -
protocol TimeLineViewProtocol: AnyObject {
    var strategy: TLStrategy? { get set }
    var presenter: TimeLinePresenterProtocol? { get set }
    func showLoadingIndicator()
    func comingTimeLineLoaded(withSections sections: [TimeLineSection])
    func previousTimeLineLoaded(withSections sections: [TimeLineSection])
    func timeLineDidFail(title: String, error: Error, type: TimeLineEventsErrorType)
    func showMonthSelector(months: [Date])
    func showMenuOptions(_ items: [MenuItem])
    func move(to event: TimeLineEvent)
    func showAlert(message: String)
    func scrollToToday()
}

