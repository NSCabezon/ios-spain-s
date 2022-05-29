//
//  ExportEventPresenter.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 23/09/2019.
//

import Foundation

class ExportEventPresenter {
    weak private var view: ExportEventViewProtocol?
    private let router: ExportEventRouterProtocol
    private let textEngine: TextsEngine
    private let interactor: ExportEventInteractorProtocol
    
    init(view: ExportEventViewProtocol, interactor: ExportEventInteractorProtocol, router: ExportEventRouterProtocol, textEngine: TextsEngine) {
        self.view = view
        self.router = router
        self.textEngine = textEngine
        self.interactor = interactor
    }
}

extension ExportEventPresenter: ExportEventPresenterProtocol {
    func viewDidLoad() {
        onShowTransactionListTap(false)
    }
    
    func didSelectBack() {
    }
    
    func onShowTransactionListTap(_ show: Bool) {
        view?.showTransactionTypeList(show)
    }
    
    func onExportTap(with selectedButton: String, and eventTypeList: [String]?) {
        switch selectedButton {
        case ExportEventString().allTimeOption:
            interactor.fetchAllEvents()
        case ExportEventString().thisMonthoOtion:
            interactor.fetchThisMonthEvents()
        case ExportEventString().withFilterAppliedOption:
            interactor.fetchFilteredEvents()
        case ExportEventString().withSpecificTypeOption:
            guard let list = eventTypeList else { return }
            interactor.fetch(with: list)
        default:
            break
        }
    }
    
    func getTransactionTypes() -> [String] {
        return textEngine.getAllTransactionType()
    }
}

extension ExportEventPresenter: ExportEventInteractorOutput {
    func fetching() {
        view?.onFetching()
    }
    
    func fetched(_ events: TimeLineEvents) {
        CalendarEventHelper.requestAcces { (granted) in
            if granted {
                let ekEvents = CalendarEventHelper.getCalendarEvents(from: events.events, with: self.textEngine)
                ekEvents.forEach({CalendarEventHelper.save($0)})
            }
        }
        view?.onFetch(events)
    }
    
    func fetchDidFail(with error: Error) {
        view?.onFetchFail(with: error)
    }  
}
