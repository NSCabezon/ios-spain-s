import Foundation

extension Date {
    
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    static func getDayOneOfTheFollowingMonth() -> Date {
        let date = Date()
        var comp = Calendar.current.dateComponents([.month, .year], from: date)
        comp.month = 1 + (comp.month ?? 0)
        comp.day = 1
        return Calendar.current.date(from: comp) ?? date
    }
}
