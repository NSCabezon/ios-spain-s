//
//  TimeLineRepositoryMock.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 16/09/2019.
//

import Foundation
@testable import FinantialTimeline

class TimeLineRepositoryMock: TimeLineRepository {
    func getDate(completion: @escaping (Result<TimeLineEvents, Error>) -> Void) {
        
    }
    
    
    func fetchCards(completion: @escaping (Result<CadsList, Error>) -> Void) {
        
    }
    
    func fetchAccounts(completion: @escaping (Result<AccountList, Error>) -> Void) {
        
    }
    
    func updateCustomEvent(_ event: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void) {
        
    }
    
    func getMasterCustomEvent(code: String, completion: @escaping (Result<PeriodicEvent, Error>) -> Void) {
        
    }
    
    func deleteEvent(id: String, completion: @escaping (Result<Bool, TimeLineRepositoryError>) -> Void) {
        
    }
    
    func deleteCustomEvent(id: String, completion: @escaping (Result<Bool, TimeLineRepositoryError>) -> Void) {
        
    }
    
    
    func loadCustomEvents(offset: String?, completion: @escaping (Result<PeriodicEvents, Error>) -> Void) {
        
    }
    
    func createAlertforEvent(_ event: TimeLineEvent, type: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
    }
    
    func deleteAlertforEvent(_ event: TimeLineEvent, completion: @escaping (Result<Bool, Error>) -> Void) {
        
    }
    
    func fetchTimeLineEventDetail(for identifier: String, completion: @escaping (Result<TimeLineEvent, Error>) -> Void) {
        
    }
    
    
    func fetchComingTimeLineEvents(date: Date, offset: String?, completion: @escaping (Result<TimeLineEvents, Error>) -> Void) {
        
    }
    
    func fetchPreviousTimeLineEvents(date: Date, offset: String?, completion: @escaping (Result<TimeLineEvents, Error>) -> Void) {
        
    }
    
    func createCustomEvent(_ event: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void) {
        let message = "OK"
        let description = event.description ?? ""
        let frequency = event.frequency?.rawValue ?? "01"
        let periodicEvent = PeriodicEvent(id: nil,
                                          userId: "227",
                                          title: event.title,
                                          description: description,
                                          frequency: frequency,
                                          startDate: "20191212", endDate: "20201212")
        let transaction = TimeLineEvent.Transaction(identifier: "5d7b4a06806ae00001520ac8",
                                                    transactionTypeString: "900",
                                                    description: event.description,
                                                    issueDate: TimeLine.dependencies.configuration?.currentDate ?? Date())
        let firstEvent = TimeLineEvent(transaction: transaction)
        
        let personalEvent = PersonalEvent(message: message, periodicEvent: periodicEvent, firstEvent: firstEvent)
        completion(.success(personalEvent))
    }
}
