//
//  TimeLineSection.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 29/07/2019.
//

import Foundation

/// Represents a TimeLine section
///
/// - eventsByDate: a TimeLine section with a date and all events in that day
/// - error: a TimeLine section with an error
enum TimeLineSection {
    
    case month(date: Date)
    case eventsByDate(date: Date, timeLineEvent: [TimeLineEvent])
    case error(error: Error)
    
    func find<Type>(by keyPath: KeyPath<TimeLineEvent, Type>, block: @escaping (Type) -> Bool) -> TimeLineEvent? {
        switch self {
        case .eventsByDate(date: _, timeLineEvent: let events):
            guard let event = events.first(where: { block($0[keyPath: keyPath]) }) else { return nil }
            return event
        default:
            return nil
        }
    }
    
    func date() -> Date? {
        switch self {
        case .eventsByDate(date: let date, timeLineEvent: _):
            return date
        default:
            return nil
        }
    }
    
    func firstTimeLineEvent() -> TimeLineEvent? {
        switch self {
        case .eventsByDate(date: _, timeLineEvent: let events):
            return events.first
        default:
            return nil
        }
    }
    
    func lastTimeLineEvent() -> TimeLineEvent? {
        switch self {
        case .eventsByDate(date: _, timeLineEvent: let events):
            return events.last
        default:
            return nil
        }
    }
    
    
    func find<Type: Equatable>(by keyPath: KeyPath<TimeLineEvent, Type>, value: Type) -> TimeLineEvent? {
        switch self {
        case .eventsByDate(date: _, timeLineEvent: let events):
            guard let event = events.first(where: { $0[keyPath: keyPath] == value }) else { return nil }
            return event
        default:
            return nil
        }
    }
    
    func index<Type: Equatable>(where keyPath: KeyPath<TimeLineEvent, Type>, value: Type) -> Int? {
        switch self {
        case .eventsByDate(date: _, timeLineEvent: let events):
            guard let index = events.firstIndex(where: { $0[keyPath: keyPath] == value }) else { return nil }
            return index
        default:
            return nil
        }
    }
    
    func index<Type>(where keyPath: KeyPath<TimeLineEvent, Type>, block: @escaping (Type) -> Bool) -> Int? {
        switch self {
        case .eventsByDate(date: _, timeLineEvent: let events):
            guard let index = events.firstIndex(where: { block($0[keyPath: keyPath]) }) else { return nil }
            return index
        default:
            return nil
        }
    }
}

extension Array where Element == TimeLineSection {
    
    func indices<Type>(where keyPath: KeyPath<TimeLineEvent, Type>, block: @escaping (Type) -> Bool) -> (Int, Int)? {
        guard let index = firstIndex(where: { $0.find(by: keyPath, block: block) != nil }), let eventIndex = self[index].index(where: keyPath, block: block) else {
            return nil
        }
        return (index, eventIndex)
    }
    
    func indices<Type: Equatable>(where keyPath: KeyPath<TimeLineEvent, Type>, value: Type) -> (Int, Int)? {
        guard let index = firstIndex(where: { $0.find(by: keyPath, value: value) != nil }), let eventIndex = self[index].index(where: keyPath, value: value) else {
            return nil
        }
        return (index, eventIndex)
    }
    
    func find<Type: Equatable>(by keyPath: KeyPath<TimeLineEvent, Type>, value: Type) -> TimeLineEvent? {
        return compactMap({ $0.find(by: keyPath, value: value) }).first
    }
    
    func allEventsByDate() -> [TimeLineSection] {
        return filter { section in
            switch section {
            case .eventsByDate: return true
            case .error: return false
            case .month: return true
            }
        }
    }
    
    func allDates() -> [Date] {
        return map { section in
            switch section {
            case .eventsByDate(date: let date, timeLineEvent: _):
                return date
            default:
                return nil
            }
        }.compactMap({ $0 })
    }
    
    func firstDate() -> Date? {
        return map { section in
            switch section {
            case .eventsByDate(date: let date, timeLineEvent: _):
                return date
            default:
                return nil
            }
        }.compactMap({ $0 }).first
    }
    
    subscript(date: Date) -> [TimeLineEvent]? {
        return compactMap {
            guard case let .eventsByDate(date: dateForEvents, timeLineEvent: events) = $0, dateForEvents.isSameDay(than: date) else { return nil }
            return events
        }.first
    }
}
