//
//  NotificationProcessor.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 16/04/2021.
//

import Foundation
import CoreFoundationLib
import CorePushNotificationsService

public protocol NotificationProcessorProtocol: AnyObject {
    /// Convert the object comming from notification events to SPPushNotification for further decision
    /// - Parameters:
    ///   - info: the dictionary arriving from notifications throught appdelegate
    ///   - date: the date associated with notification
    func parseNotificationInfo(_ systemNotification: SystemNotification, date: Date) -> SPPushNotification
    
    /// when notification processor receive this event it just forward to notificationmanager on core,
    /// usually will handle deeplinks
    /// - Parameter notification: An Object adopting PushRequestable protocol
    func handleNotification(_ notification: SPPushNotification)
    
    /// Decrement the Badge number in 1
    func decrementBadge()
    
    func clearAllBadges()
    
    func willPresentNotification(_ notification: SPPushNotification)
}

/// Will serve as notification parser and router to core manager
final class NotificationProcessor {
    private let dependencies: DependenciesResolver
    private lazy var coreNotificationManager: CorePushNotificationsManagerProtocol = {
        dependencies.resolve()
    }()
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
}

extension NotificationProcessor: NotificationProcessorProtocol {
    
    func willPresentNotification(_ notification: SPPushNotification) {
        self.coreNotificationManager.willPresentRequest(notification)
    }
    
    func handleNotification(_ notification: SPPushNotification) {
        self.coreNotificationManager.didReceivePushRequest(notification)
    }
    
    func parseNotificationInfo(_ systemNotification: SystemNotification, date: Date) -> SPPushNotification {
        return SPPushNotification(date: date, systemNotification: systemNotification)
    }
    
    func decrementBadge() {
        self.decreaseBadge()
    }
    
    func clearAllBadges() {
        self.clearBadges()
    }
}

extension NotificationProcessor: PushNotificationBadgesManagerProtocol {}
