import UserNotifications
import UIKit
import CoreFoundationLib
import SanNotificationService

final class NotificationService: SanNotificationService {
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.dependenciesEngine.register(for: NotificationServiceDependenciesProtocol.self) { _ in
            return NotificationServiceDependencies()
        }
        super.didReceive(request, withContentHandler: contentHandler)
    }
}
