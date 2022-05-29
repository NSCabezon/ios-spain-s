//
//  NotificationsManager.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 14/04/2021.
//

import CoreFoundationLib
import RetailLegacy
import CorePushNotificationsService
import ESCommons

final public class NotificationsManager: NSObject {
    private var services = [String: NotificationServiceProtocol]()
    private let dependencies: DependenciesResolver
    private let notificationProcessor: NotificationProcessorProtocol
    private var notificationReceived: SPPushNotification?
    private let sessionManager: CoreSessionManager
    private var pendingNotifications: [PushExecutableType: PushRequestable] = [:]
    private weak var handler: PushNotificationsHandler?
    private lazy var removeOtpPushNotificationsUseCase: RemoveOtpPushNotificationUseCase = {
        return RemoveOtpPushNotificationUseCase(dependenciesResolver: self.dependencies)
    }()
    public var handleNotificationTypes: [PushExecutableType] = []
        
    required init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
        self.notificationProcessor = NotificationProcessor(dependencies: dependencies)
        self.sessionManager = self.dependencies.resolve()
    }
}

// MARK: - NotificationsManagerProtocol
extension NotificationsManager: NotificationsHandlerProtocol {

    @discardableResult
    public func addService(_ notificationService: NotificationServiceProtocol) -> NotificationsManager {
        notificationService.setProcessorDelegate(self)
        self.services.updateValue(notificationService, forKey: notificationService.serviceIdentifier)
        return self
    }

    public func serviceWithIdentifier(_ identifier: String) -> NotificationServiceProtocol? {
        return self.services.first(where: {$0.key == identifier})?.value
    }
    
    public func registeredServices() -> [String]? {
        return services.compactMap({String(describing: type(of: $0.self))})
    }
    
    public func willPresentNotification(_ notification: UNNotification,
                                        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let parsedNotification = notificationProcessor.parseNotificationInfo(SystemNotification.notification(notification),
                                                                             date: notification.date.toLocalTime())
        services.service(for: parsedNotification.pushType)?.willPresentPushWIthInfo(parsedNotification,
                                                                                    withCompletionHandler: completionHandler)
    }
    
    public func didReceiveNotificationResponse(_ response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let parsedNotification = notificationProcessor.parseNotificationInfo(SystemNotification.response(response),
                                                                             date: response.notification.date.toLocalTime())
        services.service(for: parsedNotification.pushType)?.didReceive(parsedNotification,
                                                                       withCompletionHandler: completionHandler)
    }
}

// from appDelegate
extension NotificationsManager: NotificationManagerServiceCapable {
    
    public func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        self.services.forEach({$0.value.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)})
    }
    
    public func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        self.services.forEach({$0.value.didFailToRegisterForRemoteNotificationsWithError(error)})
    }
    
    public func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {}
    
    public func registerNotificationReceived(userInfo: [AnyHashable: Any], date: Date) {
        self.notificationReceived = self.notificationProcessor.parseNotificationInfo(SystemNotification.userInfo(userInfo),
                                                                           date: date.toLocalTime())
    }
}

extension NotificationsManager: NotificationProcessorProtocol {
    public func clearAllBadges() {
        self.notificationProcessor.clearAllBadges()
    }
    
    public func decrementBadge() {
        self.notificationProcessor.decrementBadge()
    }
    
    public func handleNotification(_ notification: SPPushNotification) {
        self.notificationProcessor.handleNotification(notification)
    }
    
    public func parseNotificationInfo(_ systemNotification: SystemNotification, date: Date) -> SPPushNotification {
       return SPPushNotification(date: date, systemNotification: systemNotification)
    }
    
    public func willPresentNotification(_ notification: SPPushNotification) {
        self.notificationProcessor.willPresentNotification(notification)
    }
}

extension NotificationsManager: PushNotificationsUserInfo {
    public func updateUserInfo() {
        let salesForceHandler = self.dependencies.resolve(for: InboxMessagesManager.self)
        salesForceHandler.setSubscriberKey()
    }
}

extension NotificationsManager: PushNotificationsExecutorProtocol {
    public func executeNotificationReceived() {
        guard let info = self.notificationReceived else { return }
        self.notificationReceived = nil
        self.handleNotification(info)
    }
    
    public func scheduledNotification() -> PushRequestable? {
        return self.notificationReceived
    }
    
    public func removeScheduledNotifications(forType type: PushExecutableType) {
        self.pendingNotifications.removeValue(forKey: type)
    }
}

extension NotificationsManager: PushNotificationsRegisterManagerProtocol {
    public func registerNotificationHandler(_ handler: PushNotificationsHandler) {
        self.handler = handler
        self.pendingNotifications.values.forEach(handlePush)
    }

    public func unregisterNotificationHandler() {
        self.handler = nil
    }
}

extension NotificationsManager: PushNotificationsHandler {
    public func handleNotification(_ info: PushRequestable) {
        guard let notification = info as? SPPushNotification else { return }
        self.notificationProcessor.handleNotification(notification)
    }
}

private extension NotificationsManager {
    private func handlePush(_ push: PushRequestable) {
        guard let notification = push as? SPPushNotification,
              let type = notification.executableType else { return }
        guard let handler = self.handler, handler.handleNotificationTypes.contains(type) else {
            self.pendingNotifications[type] = push
            return
        }
        handler.handleNotification(push)
        self.pendingNotifications.removeValue(forKey: type)
    }
}

private extension Dictionary where Key == String, Value == NotificationServiceProtocol {

    func service(for notificationType: NotificationType) -> NotificationServiceProtocol? {
        let serviceIdentifier: String
        switch notificationType {
        case .salesforce:
            serviceIdentifier = ServiceIdentifier.salesforce
        case .twinpush:
            serviceIdentifier = ServiceIdentifier.twinpush
        }
        return self.first { $0.key == serviceIdentifier }?.value
    }
}
