import CoreFoundationLib

final class PushNotificationViewModel {
    let title: String
    let message: String
    let date: String
    var read: Bool
    var isCheckSelected: Bool = false
    var isSwiped: Bool = false
    // Needed in order to delete the notification
    var entity: PushNotificationConformable
    
    init(title: String, message: String, date: String, read: Bool, entity: PushNotificationConformable) {
        self.title = title
        self.message = message
        self.date = date
        self.read = read
        self.entity = entity
    }
    
    func checkChanged() {
        isCheckSelected = !isCheckSelected
    }
    
    func setCheck(isOn: Bool) {
        isCheckSelected = isOn
    }
    
    func checkRead() {
        if !read { read = true }
    }
    
    func markAsRead() {
        read = true
    }
    
    func activateSwipe(_ activate: Bool) {
        isSwiped = activate
    }
}
