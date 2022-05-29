import CoreFoundationLib

final class PushNotificationManagerMock: PushNotificationPermissionsManagerProtocol {
    var completionRegisteredDevice: (() -> Void)?
    
    func getAuthStatus(completion: @escaping (AuthStatus) -> Void) {
        completion(authStatus)
    }
    
    func checkAccess(_ completion: (() -> Void)?) {
        completion?()
    }
    
    var authStatus: AuthStatus = .authorized
    var isNotificationsEnabledResult: Bool = true
    var requestAccessResult: Bool = true
    var isAlreadySetResult: Bool = true
    
    func isNotificationsEnabled(completion: @escaping (Bool) -> Void) {
        completion(self.isNotificationsEnabledResult)
    }
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        completion(requestAccessResult)
    }
    
    func isAlreadySet(_ completion: @escaping (Bool) -> Void) {
        completion(isAlreadySetResult)
    }
}
