//
//  NewCustomEventInteractor.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 06/09/2019.
//

import Foundation

class NewCustomEventInteractor: NewCustomEventInteractorProtocol {

    private let timeLineRepository: TimeLineRepository
    
    init(timeLineRepository: TimeLineRepository) {
        self.timeLineRepository = timeLineRepository
    }
    
    func createNewCustomEvent(_ customEvent: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void) {
        timeLineRepository.createCustomEvent(customEvent) { result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let personalEvent): completion(.success(personalEvent))
            }
        }
    }
    
    func updateCustomEvent(_ customEvent: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void) {
        timeLineRepository.updateCustomEvent(customEvent) { result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let personalEvent): completion(.success(personalEvent))
            }
        }
    }
    
}
