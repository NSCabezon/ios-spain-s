import Foundation

class DateFormats {
    
    enum TimeFormat: String {
        case YYYYMMDD = "yyyy-MM-dd"
        case YYYYMMDD_HHmmss = "yyyy-MM-dd HH:mm:ss"
        case YYYYMMDD_HHmmssSSS = "yyyy-MM-dd HH:mm:ss:SSS"
        case YYYYMMDD_HHmmssSSSZ = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case YYYYMMDD_HHmmssSSSSSS = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        case YYYYMMDD_HHmmssT = "yyyy-MM-dd'T'HH:mm:ssZ"
        case YYYYMMDD_HHmmssSSST = "yyyy-MM-dd'T'HH:mm:ss:SSSZ"
        case YYYYMMDD_T_HHmmss = "yyyy-MM-dd'T'HH:mm:ss"
        case YYYYMMDD_T_HHmmssSSS = "yyyy-MM-dd'T'HH:mm:ssSSS"
        case DDMMYYYY = "dd-MM-yyyy"
        case DDMMYYYY_HHmmss = "dd-MM-yyyy HH:mm:ss"
        case DDMMYYYY_HHmmssSSSSSS = "dd-MM-yyyy HH:mm:ss:SSSSSS"
        case DDMMMYYYY_HHmmss = "dd-MMM-yyyy HH:mm:ss"
        case HHmmss = "HH:mm:ss"
        case HHmmssZ = "HH:mm:ssZ"
        case yyyyMM = "yyyyMM"
        case MMyyyy = "MMyyyy"

        public init?(type: String) {
            self.init(rawValue: type)
        }
    }
    
    public class func toString(date: Date, output: TimeFormat) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = output.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
    
    public class func toDate(string: String, output: TimeFormat) -> Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = output.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: string)
    }
    
    public class func safeDate(_ valor: String?, format: TimeFormat) -> Date? {
        guard let date = parseDate(valor: valor, formats: [format]) else {
            return nil
        }
        guard checkDate(date: date) else {
            return nil
        }
        return date
    }
    
    public class func safeDateWithoutLimit(_ valor: String?) -> Date? {
        guard let date = parseDate(valor: valor, formats: [.YYYYMMDD]) else {
            return nil
        }
        guard checkDateWithoutLimit(date: date) else {
            return nil
        }
        return date
    }
    
    public class func safeDate(_ valor: String?) -> Date? {
        guard let date = parseDate(valor: valor, formats: [.YYYYMMDD]) else {
            return nil
        }
        guard checkDate(date: date) else {
            return nil
        }
        return date
    }
    
    public class func safeDateTimeZ(_ valor: String?) -> Date? {
        return parseDate(valor: valor, formats: [.YYYYMMDD_HHmmssT, .YYYYMMDD_HHmmssSSST])
    }
    
    public class func safeDateTimeT(_ valor: String?) -> Date? {
        return parseDate(valor: valor, formats: [.YYYYMMDD_T_HHmmss, .YYYYMMDD_T_HHmmssSSS])
    }
    
    public class func safeTime(_ dateString: String?) -> Date? {
        return parseDate(valor: dateString?.substring(0, 8), formats: [.HHmmss])
    }
    
    static func safeDateInverseFull(_ value: String?) -> Date? {
        guard let date = parseDate(valor: value, formats: [.DDMMYYYY_HHmmssSSSSSS]) else {
            return nil
        }
        guard checkDate(date: date) else {
            return nil
        }
        return date
    }
    
    private class func parseDate(valor: String?, formats: [TimeFormat]) -> Date? {
        guard let valor = valor, valor.trim().count > 0 else {
            return nil
        }
        for format in formats {
            if let date = toDate(string: valor, output: format) {
                return date
            }
        }
        return nil
    }
    
    private class func checkDate(date: Date) -> Bool {
        let locale = Locale(identifier: "es_ES")
        let calendar = locale.calendar
        let comp = calendar.component(.year, from: date)
        return comp > 1000 && comp < 3000
    }
    
    private class func checkDateWithoutLimit(date: Date) -> Bool {
        let locale = Locale(identifier: "es_ES")
        let calendar = locale.calendar
        let comp = calendar.component(.year, from: date)
        return comp > 1000
    }
    
    static let santanderDDMMYYYYFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = TimeFormat.DDMMYYYY.rawValue
        return formatter
    }()
}
