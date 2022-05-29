//
//  NotificationManagerBridge.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 25/04/2021.
//

import CoreFoundationLib

struct NotificationManagerBridge {
    private let dependenciesResolver: DependenciesResolver
    private let notificationManager: NotificationsHandlerProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.notificationManager = dependenciesResolver.resolve(for: NotificationsHandlerProtocol.self)
    }
}

extension NotificationManagerBridge: APPNotificationManagerBridgeProtocol {
    func getOtpPushManager() -> OtpPushManagerProtocol? {
        return self.notificationManager.serviceWithIdentifier(ServiceIdentifier.twinpush) as? OtpPushManagerProtocol
    }
}
