//
//  TimePeriodConfiguration.swift
//  Menu
//
//  Created by Mario Rosales Maillo on 2/7/21.
//

import Foundation
import CoreFoundationLib

public enum TimePeriodType {
    case monthly
    case annual
    case quarterly
    case custom
}

public struct TimePeriodConfiguration {
    var type: TimePeriodType
    var startDate: Date?
    var endDate: Date?
    var selectedText: String?
    let dependenciesResolver: DependenciesResolver

    var typeText: String {
        switch type {
        case .monthly:
            return (timeManager.toString(date: Date().addMonth(months: 2), outputFormat: .MM_YYYY) ?? "").capitalized
        case .quarterly:
            return (timeManager.toString(date: Date(), outputFormat: .MMM) ?? "").capitalized + " - " + (timeManager.toString(date: Date().addMonth(months: 2), outputFormat: .MMM) ?? "").capitalized
        case .annual:
            return (timeManager.toString(date: Date(), outputFormat: .yyyy) ?? "")
        case .custom:
            return (timeManager.toString(date: startDate, outputFormat: .dd_MMM_yyyy) ?? "") + " - " + (timeManager.toString(date: endDate, outputFormat: .dd_MMM_yyyy) ?? "")
        }
    }
    
    var titleText: String {
        switch type {
        case .monthly:
            return "analysis_label_mensualFilter"
        case .quarterly:
            return "analysis_label_quarterlyView"
        case .annual:
            return "analysis_label_annualView"
        case .custom:
            return "analysis_label_mensualFilter"
        }
    }
    
    var timeManager: TimeManager {
        self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    init(_ type: TimePeriodType, from startDate: Date? = nil, to endDate: Date? = nil, dependenciesResolver: DependenciesResolver) {
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.dependenciesResolver = dependenciesResolver
    }
}
