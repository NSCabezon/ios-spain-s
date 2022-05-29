//
//  TimeLineDetailProtocols.swift
//  Alamofire
//
//  Created by Antonio Muñoz Nieto on 08/07/2019.
//

import Foundation
import CoreFoundationLib

// MARK: - Wireframe
protocol TimeLineDetailWireframeProtocol: AnyObject {
    func dismiss()
    func goToTimeline()
    func goToEditPeriodicEvent(event: PeriodicEvent)
}
// MARK: - Presenter
protocol TimeLineDetailPresenterProtocol: AnyObject {    
    func viewDidLoad()
    func didSelectBack()
    func createAlert()
    func deleteAlert()
    func alertSelected(type: AlertType)
    func getDetail() -> TimeLineEvent?
    func getPeriodicEvent() -> PeriodicEvent?
    func deleteAlertConfirmed()
    func onAxisFromChartSelected(_ axis: Double)
    func deleteEvent()
    func deleteEventConfirmed()
    func getMasterPersonalEvent(code: String)
    func trackLink(with url: URL)
}
// MARK: - View
protocol TimeLineDetailViewProtocol: AnyObject {
    var presenter: TimeLineDetailPresenterProtocol? { get set }
    func showEventLogo(_ logo: String?, type: TimeLineEvent.TransactionType)
    func showIcon(event: TimeLineEvent)
    func showEventName(_ name: String)
    func showDisplayNumber(_ product: String?, type: String?)
    func showDescription(_ description: LocalizedStylableText, isPast: Bool)
    func showAmount(_ amount: Amount?, issueDate: Date, calculation: String?)
    func showActivity(_ activity: [TimeLineEvent.Activity], event: TimeLineEvent, hasGroupedMonths: Bool)
    func showProduct(_ product: String, type: String?)
    func showEventDate(_ date: Date)
    func showIssueDate(_ date: Date)
    func showDetails(_ deferred: TimeLineEvent.DeferredDetails?)
    func activityDidFail(with error: Error)
    func showActivityLoadingIndicator()
    func hideActivityLoadingIndicator()
    func showCTAs(_ CTAs: [CTAAction]?, for event: TimeLineEvent, ctaEngine: CTAEngine)
    func showHideAlertDropdown(alertType: String?)
    func showAlert(message: String, isAlertCreated: Bool)
    func showDeleteAlert()
    func configViewForPeriodicEvent(event: PeriodicEvent)
    func showCTAsForPeriodicEvent(ctaEngine: CTAEngine)
    func showDeleteEventAlert()
    func blockCTAButtons()
    func unblockCTAButtons()
}
// MARK: - Interactor
protocol TimeLineDetailInteractorProtocol {
    func loadDetail(for identifier: String)
    func loadPrevious(for identifier: String)
    func loadComing(for code: String)
    func createAlert(for event: TimeLineEvent)
    func deleteAlert(for event: TimeLineEvent)
    func editAlert(for event: TimeLineEvent, type: AlertType)
    func deleteEvent(_ event: TimeLineEvent)
    func deleteCustomEvent(_ event: PeriodicEvent)
    func getMasterPersonalEvent(code: String)
}
protocol TimeLineDetailInteractorOutput: AnyObject {
    func detailDidLoad(_ detail: TimeLineEvent)
    func detailDidFail(with error: Error)
    func previousDidLoad(_ detail: TimeLineEvent)
    func previousDidFail(with error: Error)
    func comingDidLoad(_ detail: TimeLineEvent)
    func comingDidFail(with error: Error)
    func alertCreated()
    func alertFailed()
    func editAlertSucceed()
    func editAlertFailed()
    func alertDeleted()
    func deleteAlertFailed()
    func deleteEventSucceed()
    func deleteEventFailed()
    func deleteCustomEventSucceed()
    func deleteCustomEventFailed()
    func getMasterPersonalEventSucceed(event: PeriodicEvent)
    func getMasterPersonalEventFailed()
}

// MARK: - Delegate
protocol TimeLineDetailDelegate: AnyObject {
    func didTappedBack()
    func deleteEventSucceed()
}
