//
//  TimeLineInteractor.swift
//  FinantialTimeline
//
//  Created by Antonio Muñoz Nieto on 02/07/2019.
//

import UIKit

class TimeLineInteractor: TimeLineInteractorProtocol {
    
    weak var output: TimeLineInteractorOutput?
    private let timeLineRepository: TimeLineRepository
    
    init(timeLineRepository: TimeLineRepository) {
        self.timeLineRepository = timeLineRepository
    }
    
    func loadComingTimeLine(date: Date, offset: String?) {
        timeLineRepository.fetchComingTimeLineEvents(date: date, offset: offset) { [weak self] result in
            switch result {
            case .failure(let error): self?.output?.comingTimeLineDidFinishWithError(error)
            case .success(let timeList): self?.output?.comingTimeLineDidFinishLoad(timeList)
            }
        }
    }
    
    func loadPreviousTimeLine(date: Date, offset: String?) {
        timeLineRepository.fetchPreviousTimeLineEvents(date: date, offset: offset) { [weak self] result in
            switch result {
            case .failure(let error): self?.output?.previousTimeLineDidFinishWithError(error)
            case .success(let timeList):
                let eventsFiltered = TimeLineEvents(offset: timeList.offset, events: FailableCodableArray(elements: timeList.events.filter({ $0.predictionIndicator == .real})))
                self?.output?.previousTimeLineDidFinishLoad(eventsFiltered)
            }
        }
    }
    
    func getDate(completion: @escaping(Date?) -> Void) {
        timeLineRepository.getDate { result in
            switch result {
            case .success(let currentDate):
                TimeLine.dependencies.configuration?.currentDate = currentDate
                completion(TimeLine.dependencies.configuration?.currentDate)
            case .failure:
                completion(nil)
            }
        }
    }
}
