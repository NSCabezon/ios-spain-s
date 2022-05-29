struct EcommerceTimeViewModel {
    let totalTime: Int
    var remainingTime: Int
    
    var totalTimeInMinutes: String {
        intToTimeFormat(totalTime)
    }
    var remainingTimeInMinutes: String {
        intToTimeFormat(remainingTime)
    }
    
    func intToTimeFormat(_ time: Int) -> String {
        let min = (time % 3600) / 60
        let sec = (time % 3600) % 60
        return String(format: "-%02d:%02d", min, sec)
    }
    
    init(totalTime: Int, remainingTime: Int) {
        self.totalTime = totalTime
        self.remainingTime = remainingTime
    }
    
    init?(notificationDate: Date, shouldFinishInMinutes minutes: Int, actualDate: Date?) {
        let shouldFinishInSeconds = minutes * 60
        guard let addedDate = Calendar.current.date(
                byAdding: .second,
                value: shouldFinishInSeconds,
                to: notificationDate
            )
        else { return nil }
        let actualDate = actualDate ?? Date()
        let remainingSeconds = Int(addedDate.timeIntervalSince(actualDate))
        guard remainingSeconds <= shouldFinishInSeconds else { return nil }
        self.totalTime = remainingSeconds
        self.remainingTime = remainingSeconds
    }
}
