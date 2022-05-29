import Foundation
import CoreFoundationLib

public class PfmDateUtil: NSObject {
    public class func defaultDate(monthsBefore: Int) -> Date {
        return Date().dateByAdding(months: -monthsBefore).firstDayOfCurrentMonth
    }
    
    public class func startAverageDate(firstTransaction: Date, monthsBefore: Int) -> Date {
        let initialDate = firstTransaction
        let defaultDate = self.defaultDate(monthsBefore: monthsBefore)
        return initialDate < defaultDate ? defaultDate : initialDate
    }
    
    public class func endAverageDate() -> Date {
        return Date().dateByAdding(months: -1).lastDayOfCurrentMonth
    }
}

extension Date {
    public func toFormattedPOSIXDateClean() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'00:00:00.000"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from:self)
    }
    public func toStringDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from:self)
    }
}

extension String {
    public func toFormattedPOSIXDateClean() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'00:00:00.000"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
    
    public func toFormattedPOSIX() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
    
    public func toFormmatedFromUTC() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: self)
    }
}
