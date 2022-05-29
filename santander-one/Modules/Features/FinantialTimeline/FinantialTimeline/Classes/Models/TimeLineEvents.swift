//
//  TimeLineEvents.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 08/07/2019.
//

import Foundation

struct TimeLineEvents: Codable {
    
    var offset: String?
    var currentDate: Date?
    private let timeLineEvents: FailableCodableArray<TimeLineEvent>
    var events: [TimeLineEvent] {
        return timeLineEvents.elements
    }
    
    init(offset: String?, events: FailableCodableArray<TimeLineEvent>) {
        self.offset = offset
        self.timeLineEvents = events
        self.currentDate = TimeLine.dependencies.configuration?.currentDate ?? Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case offset = "nextPath", timeLineEvents = "movements", currentDate
    }
}

extension Array where Element == TimeLineEvents {
    
    func allEvents() -> [TimeLineEvent] {
        return flatMap({ $0.events })
    }
}

extension TimeLineEvents: DateParseable {
    
    static var formats: [String: String] {
        return [
            "events.date": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "events.deferredDetails.issueDate": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "events.deferredDetails.schedulingDate": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "events.transaction.issueDate": "yyyy-MM-dd",
            "currentDate": "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ]
    }
}
