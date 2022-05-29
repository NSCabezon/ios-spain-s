import Foundation

public class DateModel: Codable {

    public let date: Date

    public init(date: Date) {
        self.date = date
    }

    public var day: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }

    public var month: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: date)
    }

    public var year: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }

    public var string: String {
        return day + month + year
    }
    
    public var stringReverse: String {
        return year + month + day
    }
    
    public var stringReverseWithDashSeparator: String  {
        return year + "-" + month + "-" + day
    }
}
