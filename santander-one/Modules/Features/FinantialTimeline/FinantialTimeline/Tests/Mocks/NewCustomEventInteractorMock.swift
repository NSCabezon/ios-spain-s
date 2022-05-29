//
//  NewCustomEventInteractorMock.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 13/09/2019.
//

import Foundation
@testable import FinantialTimeline

class NewCustomEventInteractorMock: NewCustomEventInteractorProtocol {
    func updateCustomEvent(_ customEvent: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void) {
        
    }
    
    
    func createNewCustomEvent(_ customEvent: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void) {
        let message = "OK"
        let description = customEvent.description ?? ""
        let frequency = customEvent.frequency?.rawValue ?? "01"
        let periodicEvent = PeriodicEvent(id: nil,
                                          userId: "227",
                                          title: customEvent.title,
                                          description: description,
                                          frequency: frequency,
                                          startDate: "20191212", endDate: "20201212")
        let transaction = TimeLineEvent.Transaction(identifier: "5d7b4a06806ae00001520ac8",
                                                    transactionTypeString: "900",
                                                    description: customEvent.description,
                                                    issueDate: TimeLine.dependencies.configuration?.currentDate ?? Date())
        let firstEvent = TimeLineEvent(transaction: transaction)
        
        let personalEvent = PersonalEvent(message: message, periodicEvent: periodicEvent, firstEvent: firstEvent)
        completion(.success(personalEvent))
    }
}
