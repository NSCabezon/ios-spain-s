import CoreDomain

public struct ManagerNotificationsDTO: Codable {
    public var unreadMessages: String
    
    public init (unreadMessages: String) {
        self.unreadMessages = unreadMessages
    }
}

extension ManagerNotificationsDTO: PersonalManagerNotificationRepresentable {}
