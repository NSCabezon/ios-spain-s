import CoreFoundationLib

struct MockSalesForce: BridgedSalesforceProtocol {
    func markAllAsRead() {}
    
    func markAsRead(notification: PushNotificationConformable) {}
    
    func getUserInbox(completion: @escaping ([PushNotificationConformable]?) -> Void) {
        let noti1 =  SalesForceNotificationMock(id: "H38Jk",
                                            title: "Hello From the other side",
                                            message: "Something dark",
                                            date: Date(),
                                            isRead: false)
        completion([noti1])
    }
    
    func delete(notification: [PushNotificationConformable], completion: @escaping (Bool) -> Void) {}
    
    func deleteAll() {}
    
    func setSubscriberKey() {}
}
