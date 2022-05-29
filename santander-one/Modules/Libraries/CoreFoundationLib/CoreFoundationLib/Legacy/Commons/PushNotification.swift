import Foundation

public enum PushNotificationType {
    case salesforce
    case twinpush
}

public struct PushNotification {
    public let id: String
    public let title: String
    public let message: String
    public let date: Date?
    public let isRead: Bool
    public let type: PushNotificationType
    
    public init(
        id: String,
        title: String,
        message: String,
        date: Date?,
        isRead: Bool,
        type: PushNotificationType
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.date = date
        self.isRead = isRead
        self.type = type
    }
    
    public func getCompleteDate(stringLoader: StringLoader, timeManager: TimeManager) -> String {
        guard let notificationDate = date else { return "" }
        
        guard let day = timeManager.toString(date: notificationDate, outputFormat: .d_MMM_yyyy), let hour =  timeManager.toString(date: notificationDate, outputFormat: .HHmm) else {
            return ""
        }
        return "\(day) \(hour)h."
    }
    
    public func calculateInboxTime(stringLoader: StringLoader, timeManager: TimeManager) -> String {
        guard let notificationDate = date, let currentDate = timeManager.getCurrentLocaleDate(inputDate: Date()) else { return "" }
        let inboxLiteral: String
        var calendar = Calendar.current
        calendar.timeZone = .current
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: notificationDate, to: currentDate)
        
        guard let days = components.day, let hours = components.hour, let minutes = components.minute else {
            return ""
        }
        
        if days > 0 {
            guard let day = timeManager.toString(date: notificationDate, outputFormat: .d_MMM_yyyy), let hour =  timeManager.toString(date: notificationDate, outputFormat: .HHmm) else {
                return ""
            }
            inboxLiteral = "\(day) \(hour)h."
        } else if hours > 0 {
            inboxLiteral = stringLoader.getString("notificationMailbox_label_untilHours", [StringPlaceholder(.number, "\(hours)")]).text
        } else {
            let minutesFinal = minutes > 0 ? minutes : 0
            inboxLiteral = stringLoader.getString("notificationMailbox_label_untilMinutes", [StringPlaceholder(.number, "\(minutesFinal)")]).text
        }
        
        return inboxLiteral
    }
	
    public func toPushNotificationEntity() -> PushNotificationEntity {
		return PushNotificationEntity(id: id, title: title, message: message, date: date, isRead: isRead)
	}
	
    public static func toPushNotificationSalesforce(notification: PushNotificationEntity) -> PushNotification {
		return PushNotification(id: notification.id, title: notification.title, message: notification.message, date: notification.date, isRead: notification.isRead, type: .salesforce)
	}
}

extension PushNotification: PushNotificationConformable {}
