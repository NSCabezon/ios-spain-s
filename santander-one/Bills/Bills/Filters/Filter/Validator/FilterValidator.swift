//
//  FilterValidator.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/20/20.
//

import Foundation
import CoreFoundationLib

enum FilterError: Error {
    case invalidDateRange(String)
}

final class FilterValidator {
    func isValid(_ filter: BillFilter) throws {
        try self.isStartDateInMinimumDateRange(filter)
        try self.isDateRangeBetweenToMonths(filter)
    }
}

private extension FilterValidator {
    func isStartDateInMinimumDateRange(_ filter: BillFilter) throws {
        let minimunDate = Date().addMonth(months: -15)
        guard let startDate = filter.dateRange.startDate else {
            throw FilterError.invalidDateRange("search_text_dateRangeMaxMin")
        }
        guard startDate > minimunDate else {
            throw FilterError.invalidDateRange("search_text_dateRangeMaxMin")
        }
    }
    
    func isDateRangeBetweenToMonths(_ filter: BillFilter) throws {
        guard let startDate = filter.dateRange.startDate,
            let endDate = filter.dateRange.endDate else {
                throw FilterError.invalidDateRange("search_text_dateRangeMaxMin")
        }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        guard days <= 60 else {
            throw FilterError.invalidDateRange("search_text_dateRangeMaxMin")
        }
    }
}
