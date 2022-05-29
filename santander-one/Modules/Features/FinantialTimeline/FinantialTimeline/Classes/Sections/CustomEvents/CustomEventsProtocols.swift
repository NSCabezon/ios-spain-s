//
//  CustomEventsProtocols.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 10/10/2019.
//

import Foundation

protocol CustomEventsViewProtocol: AnyObject {
    func loadEvents(events: [PeriodicEvent])
    func setMoreEventsAvailable(available: Bool)
    func showViewLoader()
    func hideViewLoader()
    func showItemsLoader()
    func hideItemsLoader()
    func showEvents()
    func showNoEventsAvailable()
    func showError()
}

protocol CustomEventsWireframeProtocol {
    func dismiss()
    func showDetailView(_ event: PeriodicEvent)
    func showNewCustomEvent()
}

protocol CustomEventsPresenterProtocol {
    func viewDidLoad()
    func didSelectBack()
    func didSelectEvent(index: Int)
    func loadMoreEvents()
    func newEventTapped()
}

protocol CustomEventsInteractorProtocol {
    func loadEvents(offset: String?)
}

protocol CustomEventsInteractorOutput: AnyObject {
    func eventsDidLoad(_ periodicEvents: PeriodicEvents)
    func eventsDidLoadWithError()
}
