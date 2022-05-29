//
//  TimeLineDetailInteractor.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 02/09/2019.
//

import Foundation

class TimeLineDetailInteractor: TimeLineDetailInteractorProtocol {
    
    weak var output: TimeLineDetailInteractorOutput?
    private let timeLineRepository: TimeLineRepository
    
    init(timeLineRepository: TimeLineRepository) {
        self.timeLineRepository = timeLineRepository
    }
    
    func loadDetail(for identifier: String) {
        timeLineRepository.fetchTimeLineEventDetail(for: identifier) { [weak self] result in
            switch result {
            case .success(let detail): self?.output?.detailDidLoad(detail)
            case .failure(let error): self?.output?.detailDidFail(with: error)
            }
        }
    }
    
    func loadPrevious(for identifier: String) {
        timeLineRepository.fetchTimeLineEventDetail(for: identifier) { [weak self] result in
            switch result {
            case .success(let detail): self?.output?.previousDidLoad(detail)
            case .failure(let error): self?.output?.previousDidFail(with: error)
            }
        }
    }
    
    func loadComing(for identifier: String) {
        timeLineRepository.fetchTimeLineEventDetail(for: identifier) { [weak self] result in
            switch result {
            case .success(let detail): self?.output?.comingDidLoad(detail)
            case .failure(let error): self?.output?.comingDidFail(with: error)
            }
        }
    }
    
    func createAlert(for event: TimeLineEvent) {
        timeLineRepository.createAlertforEvent(event, type: AlertType.sameDay.rawValue) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success: self.output?.alertCreated()
            case .failure: self.output?.alertFailed()
            }
        }
    }
    
    func editAlert(for event: TimeLineEvent, type: AlertType) {
        timeLineRepository.createAlertforEvent(event, type: type.rawValue) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success: self.output?.editAlertSucceed()
            case .failure: self.output?.editAlertFailed()
            }
        }
    }
    
    func deleteAlert(for event: TimeLineEvent) {
        timeLineRepository.deleteAlertforEvent(event) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success: self.output?.alertDeleted()
            case .failure: self.output?.deleteAlertFailed()
            }
        }
    }
    
    func deleteEvent(_ event: TimeLineEvent) {        
        timeLineRepository.deleteEvent(id: event.transaction.identifier) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success: self.output?.deleteEventSucceed()
            case .failure: self.output?.deleteEventFailed()
            }
        }
    }
    
    func deleteCustomEvent(_ event: PeriodicEvent) {
        guard let id = event.id else { return }
        timeLineRepository.deleteCustomEvent(id: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success: self.output?.deleteCustomEventSucceed()
            case .failure: self.output?.deleteCustomEventFailed()
            }
        }
    }
    
    func getMasterPersonalEvent(code: String) {
        timeLineRepository.getMasterCustomEvent(code: code) {  [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let event): self.output?.getMasterPersonalEventSucceed(event: event)
            case .failure: self.output?.getMasterPersonalEventFailed()
            }
        }
    }
}

