import Foundation

protocol UserActivityHandler {
    func shouldContinueUserActivity(_ userActivity: NSUserActivity) -> Bool
}

class UserActivityManager {
    let handlers: [UserActivityHandler]
    
    init(handlers: [UserActivityHandler]) {
        self.handlers = handlers
    }
}

extension UserActivityManager {
    func handle(userActivity: NSUserActivity) -> Bool {
        guard (handlers.first { $0.shouldContinueUserActivity(userActivity) }) != nil else {
            return true
        }
        return false
    }
}
