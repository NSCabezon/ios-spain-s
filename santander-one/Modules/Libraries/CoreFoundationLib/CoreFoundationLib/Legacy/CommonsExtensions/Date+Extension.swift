//
//  Date+Extension.swift
//  CoreFoundationLib
//
//  Created by Gloria Cano López on 20/12/21.
//

import Foundation


public extension Date {
    
    func getDay() -> Int {
        let day = Calendar.current.component(.day, from: self)
        return day
    }
    
    func isSameDay(than otherDate: Date) -> Bool {
        return Calendar.current.compare(self, to: otherDate, toGranularity: .day) == .orderedSame &&
        Calendar.current.compare(self, to: otherDate, toGranularity: .month) == .orderedSame &&
        Calendar.current.compare(self, to: otherDate, toGranularity: .year) == .orderedSame
    }
    
    func isSameMonth(than otherDate: Date) -> Bool {
        return Calendar.current.compare(self, to: otherDate, toGranularity: .month) == .orderedSame &&
        Calendar.current.compare(self, to: otherDate, toGranularity: .year) == .orderedSame
    }
    
    func days(to date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self))) ?? self
    }
    
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func adding(_ dateComponent: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: dateComponent, value: value, to: self) ?? Date()
    }
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

public extension Date {
    func addMonth(months: Int) -> Date {
        let components = DateComponents(month: months)
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func addDay(days: Int) -> Date {
        let components = DateComponents(day: days)
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func monthLocalizedKey() -> String {
        let keys = ["generic_label_january",
                    "generic_label_february",
                    "generic_label_march",
                    "generic_label_april",
                    "generic_label_may",
                    "generic_label_june",
                    "generic_label_july",
                    "generic_label_august",
                    "generic_label_september",
                    "generic_label_october",
                    "generic_label_november",
                    "generic_label_december"]
        return keys[self.month - 1]
    }
    
    var dayBefore: Date {
        guard let date = Calendar.current.date(byAdding: .day, value: -1, to: self) else {
            return self
        }
        return date
    }
    
    func isValidYear(_ year: Int) -> Bool {
        return !(year == 9999 || year == 1)
    }
}


public extension Date {
    // Returns the first moment of a given Date, but without considering local calendar.
    func startOfdayWithoutLocalCalendar() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59
        return Calendar.current.date(byAdding: components, to: self.startOfDay()) ?? self
    }
    
    func isDayInYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    func isDayInToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isTomorrow() -> Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    func isAfterTomorrow() -> Bool {
        let afterTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? self
        return Calendar.current.compare(self, to: afterTomorrow, toGranularity: .day) == .orderedDescending &&
        Calendar.current.compare(self, to: afterTomorrow, toGranularity: .month) == .orderedSame &&
        Calendar.current.compare(self, to: afterTomorrow, toGranularity: .year) == .orderedSame
    }
    
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func isSameYear(than otherDate: Date) -> Bool {
        return Calendar.current.compare(self, to: otherDate, toGranularity: .year) == .orderedSame
    }
}

public extension Date {
    func getDateByAdding(days: Int = 0, months: Int = 0, years: Int = 0, ignoreHours: Bool = false) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var addings: [(component: Calendar.Component, value: Int)] = [(.day, days), (.month, months), (.year, years)]
        var date = self
        let numberOfIterations = addings.count
        for _ in 0 ..< numberOfIterations {
            if let adding = addings.first,
               let result = calendar.date(byAdding: adding.component, value: adding.value, to: date) {
                date = result
                addings.removeFirst()
            }
        }
        if ignoreHours, let newDate: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date)) {
            return newDate
        } else {
            return date
        }
    }
    
    func getUtcDateByAdding(days: Int = 0, months: Int = 0, years: Int = 0) -> Date? {
        let calendar = Calendar.autoupdatingCurrent
        var addings: [(component: Calendar.Component, value: Int)] = [(.day, days), (.month, months), (.year, years)]
        var date = self
        let numberOfIterations = addings.count
        for _ in 0 ..< numberOfIterations {
            if let adding = addings.first,
               let result = calendar.date(byAdding: adding.component, value: adding.value, to: date) {
                date = result
                addings.removeFirst()
            }
        }
        
        return date.getUtcDate()
    }
    
    func getUtcDate() -> Date? {
        let calendar = Calendar.autoupdatingCurrent
        
        var components = calendar.dateComponents([.day, .month, .year], from: self)
        components.timeZone = TimeZone(abbreviation: "UTC")
        return calendar.date(from: components)
    }
    
    func startOfMonth() -> Date? {
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month, .hour], from: Calendar.current.startOfDay(for: self))
        return Calendar.current.date(from: comp)
    }
    
    func endOfMonth() -> Date? {
        var comp: DateComponents = Calendar.current.dateComponents([.month, .day, .hour], from: Calendar.current.startOfDay(for: self))
        comp.month = 1
        comp.day = -1
        guard let optionalStartOfMonth = self.startOfMonth() else {
            return nil
        }
        return Calendar.current.date(byAdding: comp, to: optionalStartOfMonth)
    }
    
    func monthOfYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let monthOfYearString = dateFormatter.string(from: self)
        return monthOfYearString
    }
    
    /// return the exact 1st day of the instance month according to local time zone.
    func startOfMonthLocalTime() -> Date? {
        let interval = Calendar.current.dateInterval(of: .month, for: self)
        return interval?.start.toLocalTime() // Without toLocalTime it give last months last date
    }
    
    func endOfMonthLocalTime() -> Date? {
        let interval = Calendar.current.dateInterval(of: .month, for: self)
        return interval?.end.toLocalTime() // Without toLocalTime it give last months last date
    }
    /// convert to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func dayInMonth() -> Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }
    
    func isBeforeFifthDayInMonth() -> Bool {
        return self.dayInMonth() < 6
    }
    func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: self) else { return 0 }
        return range.count
    }
    
    func isAfterFifteenDaysInMonth() -> Bool {
        return self.dayInMonth() >= 15
    }
    
    func days(from date: Date) -> Int? {
        Calendar.current.dateComponents([.day], from: date, to: self).day
    }
    
    func months(from date: Date) -> Int? {
        Calendar.current.dateComponents([.month], from: date, to: self).month
    }

    func endOfMonthPfm() -> Date? {
        var comp: DateComponents = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: Calendar.current.startOfDay(for: self))
        // return full date with all elements day, hour, month, minute, seconds. This is the limit to search for transactions. Month could be any, just left 1, january to keep full date format.
        comp.month = 1
        comp.day = -1
        comp.hour = 23
        comp.minute = 59
        comp.second = 59
        guard let optionalStartOfMonth = self.startOfMonth() else {
            return nil
        }
        return Calendar.current.date(byAdding: comp, to: optionalStartOfMonth)
    }
    
    func totalDays(from date: Date) -> Int {
        if self < date {
            return 0
        }
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
}


public extension Date {
    var year: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }

    var month: Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }
    
    var firstDayOfCurrentMonth: Date {
        return (Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)))!
    }
    
    var isFirstDayOfCurrentMonth: Bool {
        return self == firstDayOfCurrentMonth
    }
    
    var firstHourOfCurrentDate: Date {
        return (Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)))!
    }
    
    var lastDayOfCurrentMonth: Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfCurrentMonth)!
    }
    

    var day: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }
    
    var hour: Int {
        let calendar = Calendar.current
        return calendar.component(.hour, from: self)
    }
    
    var minute: Int {
        let calendar = Calendar.current
        return calendar.component(.minute, from: self)
    }
    
    func toFormattedSpanishDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let converted = dateFormatter.string(from: self)
        return converted
    }
    
    func toFormattedSpanishFullDateString(useHourSuffix: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        if useHourSuffix {
            dateFormatter.dateFormat = "dd/MM/yyyy - HH:mm'h.'"
        } else {
            dateFormatter.dateFormat = "dd/MM/yyyy - HH:mm"
        }
        let converted = dateFormatter.string(from: self)
        return converted
    }
    
    func toFormattedSpanishFullDateString(withEndDate end: Date, useHourSuffix: Bool = true) -> String {
        let datef = DateFormatter()
        datef.dateFormat = "dd/MM/yyyy"
        let timef = DateFormatter()
        if useHourSuffix {
            timef.dateFormat = "HH:mm'h.'"
        } else {
            timef.dateFormat = "HH:mm"
        }
        
        return "\(datef.string(from: self)) - \(timef.string(from: self)) a \(timef.string(from: end))"
    }
    
    func toFormattedSpanishMonthName() -> String {
        let datef = DateFormatter()
        datef.dateFormat = "M MMMM"
        
        return "\(datef.string(from: self))"
    }

    func toFormattedJsonDateString(useUtc: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        if useUtc {
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
        let converted = dateFormatter.string(from: self)
        return converted
    }

    func toFormattedPOSIXDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from:self)
    }
    
    func dateByAdding(years: Int) -> Date {
        let components = DateComponents(year: years)
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func dateByAdding(days: Int) -> Date {
        let components = DateComponents(day: days)
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func dateByAdding(months: Int) -> Date {
        let components = DateComponents(month: months)
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func dateByAdding(hours: Int) -> Date {
        let components = DateComponents(minute: minute)
        return Calendar.current.date(byAdding: components, to: self)!
    }

    func dateByAdding(minutes: Int) -> Date {
        let components = DateComponents(minute: minute)
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func days(from date: Date) -> [Date] {
        var days = [Date]()
        for i in 0...self.totalDays(from: date) {
            days.append(date.dateByAdding(days: i))
        }
        return days
    }
    
    func totalMonths(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date.firstDayOfCurrentMonth, to: self.firstDayOfCurrentMonth).month ?? 0
    }
    
    func totalAbsoluteMonths(from date: Date) -> Int {
        return self.totalMonths(from: date) + 1
    }
    
    var localTime: Time {
        let timef = DateFormatter()
        timef.dateFormat = "HH:mm:ss"
        
        let timeString = timef.string(from: self)
        let components = timeString.components(separatedBy: ":")
        
        return Time(hours: Int(components[0])!, minutes: Int(components[1])!, seconds: Int(components[2])!)
    }
}

public extension Date {    
    var fistDayOfQuarter: Date? {
        guard let startOfMonth = self.startOfMonth() else { return nil }
        var components = Calendar.current.dateComponents([.month, .day, .year], from: startOfMonth)

        let newMonth: Int
        switch components.month! {
        case 1,2,3: newMonth = 1
        case 4,5,6: newMonth = 4
        case 7,8,9: newMonth = 7
        case 10,11,12: newMonth = 10
        default: newMonth = 1
        }
        components.month = newMonth
        return Calendar.current.date(from: components)
    }
    
    var lastDayOfQuarter: Date? {
        var components = Calendar.current.dateComponents([.month, .day, .year], from: self)

        let newMonth: Int
        switch components.month! {
        case 1,2,3: newMonth = 3
        case 4,5,6: newMonth = 6
        case 7,8,9: newMonth = 9
        case 10,11,12: newMonth = 12
        default: newMonth = 1
        }
        components.month = newMonth
        return Calendar.current.date(from: components)?.endOfMonth()
    }
    
    var firstDayOfYear: Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year], from: self))
    }
    
    var lastDayOfYear: Date? {
        var components = Calendar.current.dateComponents([.year], from: self)
        if let startDateOfYear = Calendar.current.date(from: components) {
            components.year = 1
            components.day = -1
            return Calendar.current.date(byAdding: components, to: startDateOfYear)
        }
        return nil
    }
}
