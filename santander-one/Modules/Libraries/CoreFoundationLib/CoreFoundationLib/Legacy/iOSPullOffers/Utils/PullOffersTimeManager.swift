import Foundation

public class PullOffersTimeManager {

    public static func getUTCDate() -> Date {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = PullOffersTimeFormat.DDMMYYYY_HHmmss.rawValue
        let string = formatter.string(from: Date())
        return formatter.date(from: string) ?? Date()
    }
    
    public static func toString(date: Date?, outputFormat: PullOffersTimeFormat) -> String? {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = outputFormat.rawValue
            formatter.timeZone = TimeZone(identifier: "UTC")
            return formatter.string(from: date).lowercased()
        }
        return nil
    }
    
    public static func toStringFromCurrentLocale(date: Date?, outputFormat: PullOffersTimeFormat) -> String? {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = outputFormat.rawValue
            formatter.timeZone = TimeZone.current
            return formatter.string(from: date).lowercased()
        }
        return nil
    }
    
    public static func toDate(input: String) -> Date? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        formatter.dateFormat = PullOffersTimeFormat.YYYYMMDD.rawValue
        if let date = formatter.date(from: input) {
            return date
        }
        
        formatter.dateFormat = PullOffersTimeFormat.YYYYMMDD_HHmmss.rawValue
        if let date = formatter.date(from: input) {
            return date
        }
        
        formatter.dateFormat = PullOffersTimeFormat.DDMMYYYY.rawValue
        if let date = formatter.date(from: input) {
            return date
        }
        
        formatter.dateFormat = PullOffersTimeFormat.DDMMYYYY_HHmmss.rawValue
        if let date = formatter.date(from: input) {
            return date
        }
        
        formatter.dateFormat = PullOffersTimeFormat.YYYYMMDD2.rawValue
        if let date = formatter.date(from: input) {
            return date
        }
        
        formatter.dateFormat = PullOffersTimeFormat.YYYYMMDD_HHmmss2.rawValue
        if let date = formatter.date(from: input) {
            return date
        }
        
        formatter.dateFormat = PullOffersTimeFormat.DDMMYYYY2.rawValue
        if let date = formatter.date(from: input) {
            return date
        }
        
        formatter.dateFormat = PullOffersTimeFormat.DDMMYYYY_HHmmss2.rawValue
        if let date = formatter.date(from: input) {
            return date
        }
        
        return nil
    }
}

public enum PullOffersTimeFormat: String {
    case YYYYMMDD = "yyyy-MM-dd"
    case YYYYMMDD_HHmmss = "yyyy-MM-dd HH:mm:ss"
    case DDMMYYYY = "dd-MM-yyyy"
    case DDMMYYYY_HHmmss = "dd-MM-yyyy HH:mm:ss"
    
    case YYYYMMDD2 = "yyyy/MM/dd"
    case YYYYMMDD_HHmmss2 = "yyyy/MM/dd HH:mm:ss"
    case DDMMYYYY2 = "dd/MM/yyyy"
    case DDMMYYYY_HHmmss2 = "dd/MM/yyyy HH:mm:ss"
}
