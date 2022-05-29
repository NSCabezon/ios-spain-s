//
//  CalendatEventHelper.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 24/09/2019.
//

import Foundation
import EventKit

class CalendarEventHelper {
    static let eventStore: EKEventStore = EKEventStore()
    class func requestAcces(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    class func getCalendarEvent(from event: TimeLineEvent, with textEngine: TextsEngine) -> EKEvent? {
        var title = ""
        if let merchName = event.merchant?.name, merchName != "" {
            title = merchName
        } else {
            title = textEngine.getTransactionName(for: event)
        }
        let description = textEngine.getText(for: event)
        
        let calendarEvent = EKEvent(eventStore: eventStore)
        calendarEvent.title = title
        calendarEvent.startDate = event.date
        calendarEvent.endDate = event.date
        calendarEvent.isAllDay = true
        calendarEvent.notes = description.text
        calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
        return calendarEvent
    }
    
    class func getCalendarEvents(from events: [TimeLineEvent], with textEngine: TextsEngine) -> [EKEvent] {
        var calendarEvents = [EKEvent]()
        events.forEach ({
            guard let event = getCalendarEvent(from: $0, with: textEngine) else { return }
            calendarEvents.append(event)
        })
        return calendarEvents
    }
    
    class func save(_ event: EKEvent) {
        do {
            try eventStore.save(event, span: .thisEvent)
        } catch let error as NSError {
            debugPrint("failed to save event with error : \(error)")
        }
        
    }
}
