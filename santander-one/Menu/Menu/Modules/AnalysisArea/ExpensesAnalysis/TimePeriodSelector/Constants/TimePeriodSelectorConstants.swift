//
//  TimePeriodSelectorConstants.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 13/7/21.
//
import CoreFoundationLib

struct TimePeriodPage: PageWithActionTrackable {
    typealias ActionType = Action
    let page = "/analysis/expenses/temporary_view"
    
    enum Action: String {
        case saveMonthly = "save_monthly"
        case saveQuarterly = "save_quarterly"
        case saveYearly = "save_yearly"
        case saveCustomDate = "save_custom_date"
    }
}
