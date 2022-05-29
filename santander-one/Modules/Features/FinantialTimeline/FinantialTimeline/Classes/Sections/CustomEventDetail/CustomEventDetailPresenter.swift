//
//  CustomEventDetailPresenter.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 11/10/2019.
//

import Foundation
import CoreFoundationLib

class CustomEventDetailPresenter {
    weak private var view: TimeLineDetailViewProtocol?
    private let router: TimeLineDetailWireframeProtocol
    private let interactor: TimeLineDetailInteractorProtocol
    private let dependenciesResolver: DependenciesResolver
    private let ctaEngine: CTAEngine
    
    var periodicEvent: PeriodicEvent
    weak var delegate: TimeLineDetailDelegate?
    
    init(view: TimeLineDetailViewProtocol, router: TimeLineDetailWireframeProtocol, event: PeriodicEvent, interactor: TimeLineDetailInteractorProtocol, ctaEngine: CTAEngine, dependenciesResolver: DependenciesResolver) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.periodicEvent = event
        self.ctaEngine = ctaEngine
        self.dependenciesResolver = dependenciesResolver
    }
}

extension CustomEventDetailPresenter: TimeLineDetailPresenterProtocol {
    func viewDidLoad() {
        view?.configViewForPeriodicEvent(event: periodicEvent)
        view?.showCTAsForPeriodicEvent(ctaEngine: ctaEngine)
        trackScreen()
    }
    
    func didSelectBack() {
        delegate?.didTappedBack()
        router.dismiss()
    }
    
    func createAlert() {
        
    }
    
    func deleteAlert() {
        
    }
    
    func alertSelected(type: AlertType) {
        
    }
    
    func getDetail() -> TimeLineEvent? {
        return nil
    }
    
    func getPeriodicEvent() -> PeriodicEvent? {
        return periodicEvent
    }
    
    func deleteAlertConfirmed() {
        
    }
    
    func onAxisFromChartSelected(_ axis: Double) {
        
    }
    
    func deleteEvent() {
        view?.showDeleteEventAlert()
    }
    
    func deleteEventConfirmed() {
        interactor.deleteCustomEvent(periodicEvent)
    }
    
    func getMasterPersonalEvent(code: String) {
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

extension CustomEventDetailPresenter: TimeLineDetailInteractorOutput {

    func detailDidLoad(_ detail: TimeLineEvent) {
        
    }
    
    func detailDidFail(with error: Error) {
        
    }
    
    func alertCreated() {
        
    }
    
    func alertFailed() {
        
    }
    
    func editAlertSucceed() {
        
    }
    
    func editAlertFailed() {
        
    }
    
    func alertDeleted() {
        
    }
    
    func deleteAlertFailed() {
        
    }
    
    func deleteEventSucceed() {
        
    }
    
    func deleteEventFailed() {
        
    }
    
    func deleteCustomEventSucceed() {
        delegate?.didTappedBack()
        delegate?.deleteEventSucceed()
        router.goToTimeline()
    }
    
    func deleteCustomEventFailed() {
        view?.showAlert(message: CustomEventDetailString().alertError, isAlertCreated: false)
    }
    
    func getMasterPersonalEventSucceed(event: PeriodicEvent) {
        router.goToEditPeriodicEvent(event: event)
    }
    
    func getMasterPersonalEventFailed() {
        view?.showAlert(message: CustomEventDetailString().alertError, isAlertCreated: false)
    }

    
    func previousDidFail(with error: Error) { }
    
    func comingDidFail(with error: Error) { }
    
    func previousDidLoad(_ detail: TimeLineEvent) { }
    
    func comingDidLoad(_ detail: TimeLineEvent) { }
    
    func swipedLeft() { }
    
    func swipedRight() { }
}

extension CustomEventDetailPresenter: AutomaticScreenActionTrackable {
    var trackerPage: TimeLineRecordDetailPage {
        return TimeLineRecordDetailPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
