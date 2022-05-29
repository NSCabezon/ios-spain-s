//
//  TimeLineBuilder.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 10/07/2019.
//

import Foundation

class TimeLineBuilder {
    
    private var previousItems: [Date: [TimeLineEvent]] = [:]
    private var comingItems: [Date: [TimeLineEvent]] = [:]
    private var previousError: Error?
    private var comingError: Error?
    private let strategy: TLStrategy?
    
    init(strategy: TLStrategy?) {
        self.strategy = strategy
    }
    
    func reset() {
        previousItems = [:]
        comingItems = [:]
        previousError = nil
        comingError = nil
    }
    
    func addPreviousItems(_ items: [Date: [TimeLineEvent]]) {
        guard previousError == nil else { return }
        previousItems.merge(items, uniquingKeysWith: { $0 + $1 })
    }
    
    func addComingItems(_ items: [Date: [TimeLineEvent]]) {
        guard comingError == nil else { return }
        comingItems.merge(items, uniquingKeysWith: { $0 + $1 })
    }
    
    func setPreviousError(_ error: Error) {
        previousError = error
    }
    
    func setComingError(_ error: Error) {
        comingError = error
    }
    
    func build() -> [TimeLineSection] {
        var sections: [TimeLineSection?] = []
        sections.append(previousError.map(TimeLineSection.error))
        sections.append(contentsOf: sorted(timeLine: previousItems.map(TimeLineSection.eventsByDate), by: .orderedAscending))
        sections.append(contentsOf: sorted(timeLine: comingItems.map(TimeLineSection.eventsByDate), by: .orderedAscending))
        sections.append(comingError.map(TimeLineSection.error))
        if self.strategy?.isList() == true {
            sections = sectionsByAddingMonth(sections.compactMap({ $0 }))
        }
        return sectionsByAddingTodayEvent(sections.compactMap({ $0 }))
    }
    
    private func sectionsByAddingMonth(_ sections: [TimeLineSection]) -> [TimeLineSection] {
        let monthsAndIndices = sections.enumerated().reduce(into: [Date: Int]()) { dictionary, section in
            guard let month = section.element.date()?.startOfMonth(), dictionary[month] == nil else { return }
            dictionary[month] = section.offset
        }
        var sections = sections
        var inserted = 0
        monthsAndIndices
            .map({ ($0, $1) })
            .sorted(by: { $0.0 < $1.0 })
            .forEach { date, index in
            sections.insert(.month(date: date), at: index + inserted)
            inserted += 1
        }
        return sections
    }
    
    /// It Finds any section for today date. If not exists, it adds an empty today section
    private func sectionsByAddingTodayEvent(_ sections: [TimeLineSection]) -> [TimeLineSection] {
        guard sections[TimeLine.dependencies.configuration?.currentDate ?? Date()] == nil else { return sections }
        var sections = sections
        guard
            let lowerIndex = sections.lastIndex(where: isLowerThanToday),
            sections.firstIndex(where: isHigherThanToday) != nil
        else {
            return sections
        }
        let todayEvent = TimeLineEvent(
            transaction: TimeLineEvent.Transaction(
                transactionTypeString: TimeLineEvent.TransactionType.noEvent.rawValue,
                description: "",
                issueDate: nil
            )
        )
        sections.insert(.eventsByDate(date: TimeLine.dependencies.configuration?.currentDate ?? Date(),
                                      timeLineEvent: [todayEvent]),
                        at: lowerIndex + 1)
        return sections
    }
    
    private func isHigherThanToday(_ section: TimeLineSection) -> Bool {
        guard let date = section.date() else { return false }
        return date > TimeLine.dependencies.configuration?.currentDate ?? Date()
    }
    
    private func isLowerThanToday(_ section: TimeLineSection) -> Bool {
        guard let date = section.date() else { return false }
        return date < TimeLine.dependencies.configuration?.currentDate ?? Date()
    }
    
    private func sorted(timeLine: [TimeLineSection], by order: ComparisonResult) -> [TimeLineSection] {
        return timeLine.sorted {
            guard
                case let TimeLineSection.eventsByDate(date: firstDate, timeLineEvent: _) = $0,
                case let TimeLineSection.eventsByDate(date: secondDate, timeLineEvent: _) = $1
            else {
                return false
            }
            return firstDate.compare(secondDate) == order
        }
    }
}
