//
//  CustomEventsPresenter.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 10/10/2019.
//

import Foundation

class CustomEventsPresenter {
    
    weak private var view: CustomEventsViewProtocol?
    private let router: CustomEventsWireframeProtocol
    private let interactor: CustomEventsInteractorProtocol
    
    var customEvents: PeriodicEvents?
    var events: [PeriodicEvent] = []
    
    init(view: CustomEventsViewProtocol, router: CustomEventsWireframeProtocol, interactor: CustomEventsInteractorProtocol) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    func setMoreEventsAvailable(events: PeriodicEvents) {
        if events.nextPath != nil {
            view?.setMoreEventsAvailable(available: true)
        } else {
            view?.setMoreEventsAvailable(available: false)
        }
    }
    
    func setViewToShow(periodicEvents: PeriodicEvents) {
        if let events = periodicEvents.events {
            if events.count == 0 {
                view?.showNoEventsAvailable()
            } else {
                self.customEvents = periodicEvents
                self.events += events
                view?.loadEvents(events: events)
                view?.showEvents()
            }
        } else {
            view?.showError()
        }
    }
    
}

extension CustomEventsPresenter: CustomEventsPresenterProtocol {

    func viewDidLoad() {
        interactor.loadEvents(offset: nil)
    }
    
    func didSelectBack() {
        router.dismiss()
    }
    
    func didSelectEvent(index: Int) {
        router.showDetailView(events[index])
    }
    
    func loadMoreEvents() {
        guard let offset = customEvents?.nextPath else { return }
        interactor.loadEvents(offset: offset)
    }
    
    func newEventTapped() {
        router.showNewCustomEvent()
    }
    
    
}

extension CustomEventsPresenter: CustomEventsInteractorOutput {
    
    func eventsDidLoad(_ periodicEvents: PeriodicEvents) {
        setMoreEventsAvailable(events: periodicEvents)
        setViewToShow(periodicEvents: periodicEvents)
        view?.hideItemsLoader()
    }
    
    func eventsDidLoadWithError() {
        view?.showError()
        view?.hideItemsLoader()
    }
    
    
}
