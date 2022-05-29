//
//  PushNotificationsManagerProtocol.swift
//  CorePushNotificationsService
//
//  Created by Carlos Monfort Gómez on 2/6/21.
//

import Foundation
import CoreFoundationLib

public protocol PushNotificationsUserInfo {
    func updateUserInfo()
}

public protocol PushNotificationsExecutorProtocol {
    func executeNotificationReceived()
    func scheduledNotification() -> PushRequestable?
    func removeScheduledNotifications(forType type: PushExecutableType)
}

public protocol UpdateNotificationTokenProtocol {
    func updateToken(completion: @escaping ((_ isNew: Bool, _ returnCode: CoreFoundationLib.ReturnCodeOTPPush?) -> Void))
}

public protocol PushNotificationsRegisterManagerProtocol {
    func registerNotificationHandler(_ handler: PushNotificationsHandler)
    func unregisterNotificationHandler()
}

public protocol PushNotificationsHandler: AnyObject {
    var handleNotificationTypes: [PushExecutableType] { get }
    func handleNotification(_ info: PushRequestable)
}
