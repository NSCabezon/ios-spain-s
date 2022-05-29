//
//  LocalizedDate.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/25/20.
//

import Foundation
import CoreFoundationLib

final class LocalizedDate {
    private let dependenciesResolver: DependenciesResolver
    private let timeManager: TimeManager
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.timeManager = self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    func makeComingLocalizedDate(for date: Date?) -> LocalizedStylableText {
        guard let date = date else { return .empty }
        if date.isDayInToday() {
            return today(for: date)
        } else if date.isTomorrow() {
            return tomorrow(for: date)
        } else {
            return comingDate(for: date)
        }
    }
    
    func makeLocalizedDate(for date: Date?) -> LocalizedStylableText {
        guard let date = date else { return .empty }
        if date.isDayInToday() {
            return today(for: date)
        } else {
            return comingDate(for: date)
        }
    }
    
    func dateString(_ date: Date, format: TimeFormat) -> String {
        return self.timeManager.toStringFromCurrentLocale(
            date: date,
            outputFormat: format
            )?.uppercased() ?? ""
    }
    
    func day(_ date: Date) -> String {
        return self.timeManager.toStringFromCurrentLocale(
            date: date,
            outputFormat: .eeee
        )?.capitalized ?? ""
    }
}

private extension LocalizedDate {
    func today(for date: Date) -> LocalizedStylableText {
        return localized("generic_label_todayDate", [
            StringPlaceholder(.date, dateString(date, format: .d_MMM)),
            StringPlaceholder(.value, day(date))
        ])
    }
    
    func tomorrow(for date: Date) -> LocalizedStylableText {
        return localized("generic_label_tomorrowDate", [
            StringPlaceholder(.date, dateString(date, format: .d_MMM))
        ])
    }
    
    func comingDate(for date: Date) -> LocalizedStylableText {
        return localized("generic_label_listDate", [
            StringPlaceholder(.date, dateString(date, format: .d_MMM)),
            StringPlaceholder(.value, day(date))
        ])
    }
}
