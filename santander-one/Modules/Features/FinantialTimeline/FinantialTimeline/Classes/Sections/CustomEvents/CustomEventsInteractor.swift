//
//  CustomEventsInteractor.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 10/10/2019.
//

import Foundation

class CustomEventsInteractor: CustomEventsInteractorProtocol {

    weak var output: CustomEventsInteractorOutput?
    private let timeLineRepository: TimeLineRepository
    
    init(timeLineRepository: TimeLineRepository) {
        self.timeLineRepository = timeLineRepository
    }
    
    func loadEvents(offset: String?) {
        timeLineRepository.loadCustomEvents(offset: offset) { [weak self] result in
            switch result {
            case .failure: self?.output?.eventsDidLoadWithError()
            case .success(let result): self?.output?.eventsDidLoad(result)
            }
        }
    }
    
}
