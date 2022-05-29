public struct OTPTimeViewModel {
    public let totalTime: Int
    public var remainingTime: Int
    
    public var totalTimeInMinutes: String {
        intToTimeFormat(totalTime)
    }
    public var remainingTimeInMinutes: String {
        intToTimeFormat(remainingTime)
    }
    
    func intToTimeFormat(_ time: Int) -> String {
        let min = (time % 3600) / 60
        let sec = (time % 3600) % 60
        return String(format: "%02d:%02d", min, sec)
    }
}

public struct OTPCodeViewModel {
    public let code: String
    public let date: Date
    public let time: OTPTimeViewModel
    
    public var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM ' | ' HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }
    
    public init(code: String, date: Date, totalTime: Int, remainingTime: Int) {
        self.code = code
        self.date = date
        self.time = OTPTimeViewModel(totalTime: totalTime,
                                     remainingTime: remainingTime)
    }
    
    public init?(code: String, notificationDate: Date, shouldFinishIn seconds: Int, actualDate: Date?) {
        self.code = code
        self.date = notificationDate
        guard
            let addedDate = Calendar.current.date(byAdding: .second,
                                                  value: seconds,
                                                  to: notificationDate)
            else { return nil }
        let actualDate = actualDate ?? Date()
        let remainingSeconds = Int(addedDate.timeIntervalSince(actualDate))
        guard remainingSeconds <= seconds else { return nil }
        self.time = OTPTimeViewModel(totalTime: remainingSeconds,
                                     remainingTime: remainingSeconds)
    }
}
