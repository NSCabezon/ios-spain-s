//
//  File.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 04/09/2019.
//

import Foundation


// Output
struct CreateCustomEvent: Codable {
    let id: String?
    let title: String
    let description: String?
    let startDate: String
    let endDate: String?
    let frequency: Frequency?
}

enum Frequency: String, Codable {
    case withoutFrequency = "00"
    case weekly = "01"
    case everyTwoWeeks = "02"
    case monthly = "03"
    case annually = "04"
}

extension CreateCustomEvent: DateParseable {

    static var formats: [String: String] {
        return  [
            "startDate": "yyyyMMdd",
            "endDate": "yyyyMMdd"
        ]
    }
}

// Response
struct PersonalEvent: Codable {
    let message: String
    let periodicEvent: PeriodicEvent?
    let firstEvent: TimeLineEvent
}


struct PeriodicEvent: Codable {
    let id: String?
    let userId: String
    let title: String
    let description: String?
    let frequency: String
    let startDate: String
    let endDate: String?
}

struct PeriodicEvents: Codable {
    let userId: String
    let events: [PeriodicEvent]?
    let nextPath: String?
    
    enum CodingKeys: String, CodingKey {
        case events = "periodicEvents", userId, nextPath
    }
    
}

extension PersonalEvent: DateParseable {
    
    static var formats: [String: String] {
        return [
            "firstEvent.date": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "firstEvent.deferredDetails.issueDate": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "firstEvent.deferredDetails.schedulingDate": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "firstEvent.transaction.issueDate": "yyyy-MM-dd"
        ]
    }
}
