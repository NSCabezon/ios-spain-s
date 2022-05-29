//
//  TimeSelectorViewRepresentable.swift
//  CoreDomain
//
//  Created by Jose Javier Montes Romero on 3/2/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain

extension TimeViewOptions {

    var timeViewLocalizedKey: String {
        switch self {
        case .mounthly:
            return "generic_label_monthly"
        case .quarterly:
            return "generic_label_quarterly"
        case .yearly:
            return "generic_label_annual"
        case .customized:
            return "generic_label_custom"
        }
    }
    
    var homeText: String {
        switch self {
        case .mounthly:
            return localized("analysis_label_mensualFilter").text
        case .quarterly:
            return localized("analysis_label_quarterlyFilter").text
        case .yearly:
            return localized("analysis_label_annualFilter").text
        case .customized:
            return localized("analysis_label_customFilter").text
        }
    }
    
    var trackValue: String {
        switch self {
        case .mounthly:   return "monthly"
        case .quarterly:  return "quarterly"
        case .yearly:     return "annual"
        case .customized: return "customised"
        }
    }
}

class DefatultTimeSelectorModel: TimeSelectorRepresentable {
    var timeViewSelected: TimeViewOptions
    var startDateSelected: Date?
    var endDateSelected: Date
    
    init() {
        self.timeViewSelected = .mounthly
        self.endDateSelected = Date(timeIntervalSinceNow: 0)
    }
    
    init(timeViewSelected: TimeViewOptions, startDateSelected: Date?, endDateSelected: Date) {
        self.timeViewSelected = timeViewSelected
        self.startDateSelected = startDateSelected
        self.endDateSelected = endDateSelected
    }
    
    func clearDates() {
        self.startDateSelected = nil
        self.endDateSelected = Date(timeIntervalSinceNow: 0)
    }
}
