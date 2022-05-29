//
//  ExportEventInteractor.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 23/09/2019.
//

import Foundation

class ExportEventInteractor: ExportEventInteractorProtocol {
    weak var output: ExportEventInteractorOutput?
    private let repository: TimeLineRepository
    
    init(repository: TimeLineRepository) {
        self.repository = repository
    }
    
    func fetchAllEvents() {
        output?.fetching()
        repository.fetchComingTimeLineEvents(date: TimeLine.dependencies.configuration?.currentDate ?? Date(),
                                             offset: nil) { [weak self] result in
           switch result {
           case .failure(let error): self?.output?.fetchDidFail(with: error)
           case .success(let timeList): self?.output?.fetched(timeList)
            }
        }
    }
    
    func fetchThisMonthEvents() {
        output?.fetching()
        debugPrint("fetch months")
    }
    
    func fetchFilteredEvents() {
        output?.fetching()
        debugPrint("fetch filtered")
    }
    
    func fetch(with eventType: [String]) {
        output?.fetching()
        debugPrint("fetch by type")
    }
}
