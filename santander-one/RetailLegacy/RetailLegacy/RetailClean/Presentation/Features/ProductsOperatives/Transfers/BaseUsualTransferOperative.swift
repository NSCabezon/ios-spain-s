import Foundation
import CoreFoundationLib

protocol BaseUsualTransferOperative: Operative {}

extension BaseUsualTransferOperative {
    func operativeDidFinish() {
        NotificationCenter.default.post(name: Notifications.UsualTransferOperativeNotifications.operativeDidFinish, object: self)
    }
}
