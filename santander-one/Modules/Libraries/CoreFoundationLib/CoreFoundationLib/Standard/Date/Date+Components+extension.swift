//
//  Date+Compoents+extension.swift
//  CoreFoundationLib
//
//  Created by Juan Carlos López Robles on 1/18/22.
//

import Foundation

public extension Date {
    enum Component {
        case year(Int?)
        case month(Int?)
        case day(Int?)
        case hour(Int?)
        case minute(Int?)
        case second(Int?)
    }
    
    func getDate(component: Component) -> Date {
        var dateComponent = DateComponents()
        switch component {
        case let .year(numberOfYears):
            dateComponent.year = numberOfYears
        case let .month(numberOfMonths):
            dateComponent.month = numberOfMonths
        case let .day(numberOfDays):
            dateComponent.day = numberOfDays
        case let .hour(numberOfHours):
            dateComponent.hour = numberOfHours
        case let .minute(numberOfMinutes):
            dateComponent.minute = numberOfMinutes
        case let .second(numberOfsecond):
            dateComponent.second = numberOfsecond
        }

        let date = Date()
        return Calendar.current.date(byAdding: dateComponent, to: date) ?? Date()
    }
}
