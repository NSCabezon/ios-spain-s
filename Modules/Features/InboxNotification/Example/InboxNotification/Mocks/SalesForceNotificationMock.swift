import CoreFoundationLib

struct SalesForceNotificationMock: PushNotificationConformable {
    var identifier: String
    var title: String
    var message: String
    var date: Date?
    var isRead: Bool
}
