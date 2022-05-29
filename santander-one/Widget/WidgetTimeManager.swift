import Foundation

class WidgetTimeManager: TimeManager {
    
    func getMonth(date: Date) -> String {
        switch date.getMonth() {
        case 1:
            return "ENE"//getPlainString("generic_label_january")
        case 2:
            return "FEB"//getPlainString("generic_label_february")
        case 3:
            return "MAR"//getPlainString("generic_label_march")
        case 4:
            return "ABR"//getPlainString("generic_label_april")
        case 5:
            return "MAY"//getPlainString("generic_label_may")
        case 6:
            return "JUN"//getPlainString("generic_label_june")
        case 7:
            return "JUL"//getPlainString("generic_label_july")
        case 8:
            return "AGO" //"getPlainString("generic_label_august")
        case 9:
            return "SEP"//getPlainString("generic_label_september")
        case 10:
            return "OCT"//getPlainString("generic_label_october")
        case 11:
            return "NOV"//getPlainString("generic_label_november")
        case 12:
            return "DIC"//getPlainString("generic_label_december")
        default:
            return ""
        }
    }

    func fromString(input: String?, inputFormat: TimeFormat) -> Date? {
        if let input = input {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = inputFormat.rawValue
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
//            dateFormatter.locale = currentLanguage.languageType.locale
            return dateFormatter.date(from: input)
        }
        return nil
    }
    
    func toString(input: String?, inputFormat: TimeFormat, outputFormat: TimeFormat) -> String? {
        if let input = input, let date = fromString(input: input, inputFormat: inputFormat) {
            return toString(date: date, outputFormat: outputFormat)
        }
        return nil
    }
    
    func toString(date: Date?, outputFormat: TimeFormat) -> String? {
        return toString(date: date, outputFormat: outputFormat, timeZone: .utc)
    }
    
    func toString(date: Date?, outputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> String? {
        if let date = date, isValidDate(date) {
            switch outputFormat {
            case .MMM:
                return getShortenedMonth(date: date)
            case .MMMM:
                return getMonth(date: date)
            default:
                let formatter = DateFormatter()
                formatter.dateFormat = outputFormat.rawValue
                if timeZone == .utc {
                    formatter.timeZone = TimeZone(identifier: "UTC")
                }
//                formatter.locale = currentLanguage.languageType.locale
                return formatter.string(from: date).lowercased()
            }
        }
        return nil
    }
    
    func getShortenedMonth(date: Date) -> String? {
        return getMonth(date: date).substring(0, 3)
    }
    
    func toStringFromCurrentLocale(date: Date?, outputFormat: TimeFormat) -> String? {
        if let date = date, isValidDate(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = outputFormat.rawValue
            formatter.timeZone = TimeZone.current
//            formatter.locale = currentLanguage.languageType.locale
            return formatter.string(from: date).lowercased()
        }
        return nil
    }
    
    func isValidDate(_ date: Date) -> Bool {
        return isValidYear(date.getYear())
    }
    
    func isValidYear(_ year: Int) -> Bool {
        return !(year == 9999 || year == 1)
    }
}
