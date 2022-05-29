//
//  PeriodTextManager.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 7/4/22.
//
import CoreFoundationLib

struct PeriodTextManager: Hashable {
    var startPeriod: Date
    var endPeriod: Date
    
    func getMonthText(format: String? = nil) -> String {
        let timeFormat = format ?? TimeFormat.MMMM_YYYY.rawValue
        return startPeriod.toString(format: timeFormat).capitalized
    }
    
    func getQuarterText(_ dashFormat: String? = nil, startDateFormat: String? = nil, endDateFormat: String? = nil) -> String {
        let startFormat = startDateFormat ?? TimeFormat.MMM.rawValue
        let endFormat = endDateFormat ?? TimeFormat.MMM_yyyy.rawValue
        let startPeriodText = startPeriod.toString(format: startFormat).capitalized
        let endPeriodText = endPeriod.toString(format: endFormat).capitalized
        let dash = dashFormat ?? " - "
        return startPeriodText + dash + endPeriodText
    }
    
    func getAnualText() -> String {
        return startPeriod.toString(format: TimeFormat.yyyy.rawValue)
    }
    
    func getCustomDateText(_ dashFormat: String? = nil) -> String {
        let startPeriodText = startPeriod.toString(format: TimeFormat.dd_MMM_yyyy.rawValue).capitalized
        let endPeriodText = endPeriod.toString(format: TimeFormat.dd_MMM_yyyy.rawValue).capitalized
        let dash = dashFormat ?? " - "
        return startPeriodText + dash + endPeriodText
    }
}
