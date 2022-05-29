import CoreFoundationLib

class MockTimeManager: TimeManager {
    func fromString(input: String?, inputFormat: String) -> Date? {
        Date()
    }
    
    func fromString(input: String?, inputFormat: String, timeZone: TimeManagerTimeZone) -> Date? {
        Date()
    }
    
    func fromString(input: String?, inputFormat: TimeFormat) -> Date? {
        Date()
    }
    
    func fromString(input: String?, inputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> Date? {
        Date()
    }
    
    func toString(date: Date?, outputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> String? {
        ""
    }
    
    func toString(input: String?, inputFormat: TimeFormat, outputFormat: TimeFormat) -> String? {
        ""
    }
    
    func toString(date: Date?, outputFormat: TimeFormat) -> String? {
        ""
    }
    
    func toStringFromCurrentLocale(date: Date?, outputFormat: TimeFormat) -> String? {
        ""
    }
    
    func getCurrentLocaleDate(inputDate: Date?) -> Date? {
        Date()
    }
}
