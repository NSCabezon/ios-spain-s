//
//  TimeLineDetailPresenter.swift
//  Alamofire
//
//  Created by Antonio Muñoz Nieto on 08/07/2019.
//

import Foundation
import CoreFoundationLib

enum AlertType: String {
    case sameDay = "0"
    case dayBefore = "1"
    case weekBefore = "2"
}

class TimeLineDetailPresenter {

    weak private var view: TimeLineDetailViewProtocol?
    private let router: TimeLineDetailWireframeProtocol
    private var event: TimeLineEvent
    private var previousEvent: TimeLineEvent?
    private var comingEvent: TimeLineEvent?
    private let textsEngine: TextsEngine
    weak var delegate: TimeLineDetailDelegate?
    private let ctaEngine: CTAEngine
    private let interactor: TimeLineDetailInteractorProtocol
    private var detailActivityGrouped: [TimeLineEvent.Activity]?
    private let dependenciesResolver: DependenciesResolver
    
    let merchantColors = TimelineCellMerchantColors.shared
    var alertTypeSelectedInView: AlertType?
    var eventAlertType: AlertType?
    var updatingFromAxis: Bool = false

    init(view: TimeLineDetailViewProtocol, interactor: TimeLineDetailInteractorProtocol, router: TimeLineDetailWireframeProtocol, event: TimeLineEvent, textsEngine: TextsEngine, ctaEngine: CTAEngine, dependenciesResolver: DependenciesResolver) {
        self.view = view
        self.router = router
        self.event = event
        self.textsEngine = textsEngine
        self.ctaEngine = ctaEngine
        self.interactor = interactor
        self.dependenciesResolver = dependenciesResolver
    }
}

// MARK: - private functions
extension TimeLineDetailPresenter {
    private func setAlertType(from detail: TimeLineEvent) {
        switch detail.deferredDetails?.alertType {
        case "0": eventAlertType = AlertType.sameDay
        case "1": eventAlertType = AlertType.dayBefore
        case "2": eventAlertType = AlertType.weekBefore
        default:()
        }
    }

    private func groupActivity(from detail: TimeLineEvent) -> Bool {
        guard let activity = detail.activity, activity.count > 1 else {
            view?.activityDidFail(with: TimeLineError.oneActivity)
            return false
        }
        let detailActivityGrouped: [TimeLineEvent.Activity] = activity.reduce([]) { activities, activity in
            guard let index = activities.firstIndex(where: { $0.date.isSameMonth(than: activity.date) }) else {
                return activities + [activity]
            }
            var activities = activities
            activities[index] = TimeLineEvent.Activity(identifier: activities[index].identifier, date: activity.date, value: activities[index].value + activity.value)
            return activities
        }
        let sorted = detailActivityGrouped.sorted(by: { $0.date < $1.date })
        self.detailActivityGrouped = sorted
        return sorted.count < activity.count
    }

    private func setDetailView() {
        view?.showEventDate(event.date)

        if merchantColors.showIconWith(event: event) {
            view?.showIcon(event: event)
        } else {
            view?.showEventLogo(event.merchant?.logo, type: event.transaction.type)
        }

        if let name = event.merchant?.name, name != "" {
            view?.showEventName(name)
        } else {
            view?.showEventName(textsEngine.getTransactionName(for: event))
        }
        
        view?.showDisplayNumber(event.product?.displayNumber, type: event.product?.typeString)

        self.setAlertType(from: event)
        view?.showHideAlertDropdown(alertType: event.deferredDetails?.alertType)

        view?.showDetails(event.deferredDetails)

        switch event.transaction.type {
        case .personalEvent, .customEvent:
            view?.showDescription(applyStyles(to: event.transaction.description ?? ""), isPast: textsEngine.getEventIsPast(for: event))
        default:
            view?.showDescription(textsEngine.getDetailText(for: event), isPast: textsEngine.getEventIsPast(for: event))
        }
        if let issueDate = event.transaction.issueDate {
            view?.showIssueDate(issueDate)
        }

        view?.showAmount(event.amount, issueDate: event.date, calculation: event.transaction.getDisclaimer())

        let hasGroupedMonths = self.groupActivity(from: event)
        _ = self.groupActivity(from: event)

        if let grouped = self.detailActivityGrouped {
            view?.showActivity(grouped, event: event, hasGroupedMonths: hasGroupedMonths)
        }
        self.setAlertType(from: event)
        view?.showHideAlertDropdown(alertType: event.deferredDetails?.alertType)

        if updatingFromAxis {
            TimeLineDetailRouter.clearPager(dependencies: TimeLine.dependencies, event: event, delegate: delegate)
        }
        loadPreviousFor(from: event)
        loadComingFor(from: event)
        updatingFromAxis = false
    }

    func loadPreviousFor(from event: TimeLineEvent) {
        guard let previousCode = event.getPreviousEvent() else { return }
        interactor.loadPrevious(for: previousCode)
    }

    func loadComingFor(from event: TimeLineEvent) {
        guard let comingCode = event.getComingEvent() else { return }
        interactor.loadComing(for: comingCode)
    }
}

// MARK: - TimeLineDetailPresenterProtocol
extension TimeLineDetailPresenter: TimeLineDetailPresenterProtocol {
    func viewDidLoad() {
        setDetailView()
        interactor.loadDetail(for: event.identifier)
        trackScreen()
    }

    func didSelectBack() {
        delegate?.didTappedBack()
        router.dismiss()
    }

    func createAlert() {
        alertTypeSelectedInView = AlertType.sameDay
        interactor.createAlert(for: event)
    }

    func deleteAlert() {
        view?.showDeleteAlert()
    }

    func alertSelected(type: AlertType) {
        if type != eventAlertType {
            eventAlertType = type
            alertTypeSelectedInView = type
            interactor.editAlert(for: event, type: type)
        }
    }

    func getDetail() -> TimeLineEvent? {
        return event
    }
    
    func getPeriodicEvent() -> PeriodicEvent? {
        return nil
    }
    

    func deleteAlertConfirmed() {
        interactor.deleteAlert(for: event)
    }

    func onAxisFromChartSelected(_ axis: Double) {
        let index = Int(axis)
        guard let activity = detailActivityGrouped?[index] else { return }
        updatingFromAxis = true
        interactor.loadDetail(for: activity.identifier)
    }

    func deleteEvent() {
        view?.showDeleteEventAlert()
    }

    func deleteEventConfirmed() {
        interactor.deleteEvent(event)
    }
    
    func getMasterPersonalEvent(code: String) {
        view?.blockCTAButtons()
        interactor.getMasterPersonalEvent(code: code)
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

// MARK: - TimeLineDetailInteractorOutput
extension TimeLineDetailPresenter: TimeLineDetailInteractorOutput {
    func detailDidLoad(_ detail: TimeLineEvent) {
        self.event = detail
        self.setDetailView()
        view?.showCTAs(event.transaction.getCTAs(), for: event, ctaEngine: ctaEngine)
    }

    func detailDidFail(with error: Error) {
        view?.activityDidFail(with: error)
        view?.showAlert(message: TimeLineDetailString().alertError, isAlertCreated: false)
        view?.showCTAs(event.transaction.getCTAs(), for: event, ctaEngine: ctaEngine)
    }

    func alertCreated() {
        interactor.loadDetail(for: event.identifier)
        view?.showAlert(message: TimeLineDetailString().alerCreated, isAlertCreated: true)
        view?.hideActivityLoadingIndicator()
    }

    func alertFailed() {
        view?.showAlert(message: TimeLineDetailString().alertError, isAlertCreated: false)
    }

    func editAlertSucceed() {
        view?.showAlert(message: TimeLineDetailString().alertEdited, isAlertCreated: false)
        view?.hideActivityLoadingIndicator()
    }

    func editAlertFailed() {
        view?.showAlert(message: TimeLineDetailString().alertError, isAlertCreated: false)
        view?.hideActivityLoadingIndicator()
        detailDidLoad(event)
    }

    func alertDeleted() {
        view?.showAlert(message: TimeLineDetailString().alertDeleted, isAlertCreated: false)
        view?.hideActivityLoadingIndicator()
        interactor.loadDetail(for: event.identifier)
    }

    func deleteAlertFailed() {
        view?.showAlert(message: TimeLineDetailString().alertError, isAlertCreated: false)
        view?.hideActivityLoadingIndicator()
    }

    func deleteEventSucceed() {
        delegate?.didTappedBack()
        delegate?.deleteEventSucceed()
        router.goToTimeline()
    }

    func deleteEventFailed() {
        view?.showAlert(message: CustomEventDetailString().alertError, isAlertCreated: false)
    }

    func deleteCustomEventSucceed() { }

    func deleteCustomEventFailed() { }
    
    func getMasterPersonalEventSucceed(event: PeriodicEvent) {
        view?.unblockCTAButtons()
        router.goToEditPeriodicEvent(event: event)
    }
    
    func getMasterPersonalEventFailed() {
        view?.unblockCTAButtons()
        view?.showAlert(message: CustomEventDetailString().alertError, isAlertCreated: false)
    }
    
    func previousDidLoad(_ detail: TimeLineEvent) {
        self.previousEvent = detail
        TimeLineDetailRouter.appendPrevious(dependencies: TimeLine.dependencies, event: detail, delegate: delegate)
    }

    func previousDidFail(with error: Error) {
        self.previousEvent = nil
        view?.showAlert(message: CustomEventDetailString().alertError, isAlertCreated: false)
    }

    func comingDidLoad(_ detail: TimeLineEvent) {
        self.comingEvent = detail
        TimeLineDetailRouter.appendComing(dependencies: TimeLine.dependencies, event: detail, delegate: delegate)
    }

    func comingDidFail(with error: Error) {
        self.previousEvent = nil
        view?.showAlert(message: CustomEventDetailString().alertError, isAlertCreated: false)
    }
}

extension TimeLineDetailPresenter: AutomaticScreenActionTrackable {
    var trackerPage: TimeLineRecordDetailPage {
        return TimeLineRecordDetailPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
