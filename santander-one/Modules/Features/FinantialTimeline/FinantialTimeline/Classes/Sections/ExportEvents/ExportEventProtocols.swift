//
//  ExportEventProtocols.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 23/09/2019.
//

import Foundation

// MARK: - View
protocol ExportEventViewProtocol: AnyObject {
    func onFetching()
    func onFetchFail(with error: Error)
    func onFetch(_ events: TimeLineEvents)
    func showTransactionTypeList(_ show: Bool)
}

// MARK: - Interactor
protocol ExportEventInteractorProtocol: AnyObject {
    func fetchAllEvents()
    func fetchThisMonthEvents()
    func fetchFilteredEvents()
    func fetch(with eventType: [String])
}

// MARK: - Presenter
protocol ExportEventPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectBack()
    func onExportTap(with selectedButton: String, and eventTypeList: [String]?)
    func onShowTransactionListTap(_ show: Bool)
    func getTransactionTypes() -> [String]
}

// MARK: - Router
protocol ExportEventRouterProtocol: AnyObject {
    func dismiss()
}

protocol ExportEventInteractorOutput: AnyObject {
    func fetching()
    func fetched(_ events: TimeLineEvents)
    func fetchDidFail(with error: Error)
}

// MARK: - Delegate
protocol ExportEventDelegate: AnyObject {
}
