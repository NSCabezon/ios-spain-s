import Foundation

public enum Seasons {
    case winter
    case summer
    case autumn
    case spring
}

extension Date {
    
    func firstOfNextMonth() -> Date {
        let today = Date()
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: today)
        return getDateByAdding(days: -(components.day ?? 0) + 1, months: 1)
    }
    
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

    public func getYear() -> Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }

    public func getMonth() -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }
    
    public func getWeek() -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }

    /**
     Returns the season of the actual date.
    */
    public func getSeason() -> Seasons {
        let actualCalendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()

        dateComponents.month = 3
        dateComponents.day = 21

        guard let springStartDate = actualCalendar.date(from: dateComponents)
                else {
            fatalError("Error while transforming predefined dates into dates.")
        }

        dateComponents.month = 12
        dateComponents.day = 21

        guard let winterStartDate = actualCalendar.date(from: dateComponents)
                else {
            fatalError("Error while transforming predefined dates into dates.")
        }

        dateComponents.month = 6
        dateComponents.day = 21

        guard let summerStartDate = actualCalendar.date(from: dateComponents)
                else {
            fatalError("Error while transforming predefined dates into dates.")
        }

        dateComponents.month = 9
        dateComponents.day = 21

        guard let autumnStartDate = actualCalendar.date(from: dateComponents)
                else {
            fatalError("Error while transforming predefined dates into dates.")
        }

        dateComponents.day = 31
        dateComponents.month = 12

        guard let yearEnd = actualCalendar.date(from: dateComponents)
                else {
            fatalError("Error while transforming predefined dates into dates.")
        }

        dateComponents.day = 1
        dateComponents.month = 1

        guard let yearStart = actualCalendar.date(from: dateComponents)
                else {
            fatalError("Error while transforming predefined dates into dates.")
        }

        let newDate = actualCalendar.dateComponents([.day, .month], from: self)

        guard let date = actualCalendar.date(from: newDate) else {
            fatalError("Error while transforming actual date into date.")
        }

        switch date {
        case springStartDate..<summerStartDate:
            return .spring
        case summerStartDate..<autumnStartDate:
            return .summer
        case autumnStartDate..<winterStartDate:
            return .autumn
        case yearStart..<springStartDate, winterStartDate...yearEnd:
            return .winter
        default:
            fatalError("Error when defining seasons.")
        }
    }
    
    public static func getPreviousMonth(_ lessNumber: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: -lessNumber, to: Date())
    }
    
    public static func getNextMonth(_ date: Date) -> Date? {
        return Calendar.current.date(byAdding: .month, value: +1, to: date)
    }
    
    public static func halfMonth(_ date: Date) -> Date? {
        let dateComponent = DateComponents(year: date.year, month: date.month)
        let calendar = Calendar.current
        
        guard
            let date = calendar.date(from: dateComponent),
            let range = calendar.range(of: .day, in: .month, for: date) else { return nil }
        
        let dayNumber = range.count == 16 ? (range.count / 2 ) - 1 : range.count / 2
        
        return calendar.date(byAdding: .day, value: dayNumber, to: date)
    }
}

protocol DateRangeValidatorCapable {}

extension DateRangeValidatorCapable {
    
    public func createValidDateRange(from: Date?, to: Date?, maximumDaysBetweenDates: Int, forLastMonths: Int) -> (Date?, Date?) {
        switch (from == nil, to == nil) {
        case (true, true):
            let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -maximumDaysBetweenDates, to: Date())
            
            return (sixtyDaysAgo, Date())
        case (true, false):
            let daysBefore = Calendar.current.date(byAdding: .day, value: -maximumDaysBetweenDates, to: to!)
            var lowerLimitDate = daysBefore
            if let daysBefore = daysBefore, let fiftyMonthsAgo = Calendar.current.date(byAdding: .month, value: -forLastMonths, to: Date()) {
                lowerLimitDate = max(daysBefore, fiftyMonthsAgo)
            }
            
            return (lowerLimitDate, to)
        case (false, true):
            let sixtyDaysAfter = Calendar.current.date(byAdding: .day, value: maximumDaysBetweenDates, to: from!)
            var lowerLimitDate = sixtyDaysAfter
            if let sixtyDaysAfter = sixtyDaysAfter {
                lowerLimitDate = min(sixtyDaysAfter, Date())
            }
            
            return (from, lowerLimitDate)
        case (false, false):
            
            return (from, to)
        }
    }
}
