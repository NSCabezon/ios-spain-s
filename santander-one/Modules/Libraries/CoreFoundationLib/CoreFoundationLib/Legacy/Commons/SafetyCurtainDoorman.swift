//
//  SafetyCurtainDelegate.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 29/6/21.
//

import Foundation

public protocol SafetyCurtainDoorman: class {
    func safetyCurtainSafeguardEventWillBegin()
    func safetyCurtainSafeguardEventDidFinish()
}

public enum SafetyCurtainDoormanNotifications {
    public static let safeguardEventWillBeginNotification = Notification.Name("safeguardEventWillBeginNotification")
    public static let safeguardEventDidFinishNotification = Notification.Name("safeguardEventDidFinishNotification")
}

public extension SafetyCurtainDoorman {
    func safetyCurtainSafeguardEventWillBegin() {
        let notification = SafetyCurtainDoormanNotifications.safeguardEventWillBeginNotification
        post(notification: notification)
    }
    
    func safetyCurtainSafeguardEventDidFinish() {
        let notification = SafetyCurtainDoormanNotifications.safeguardEventDidFinishNotification
        post(notification: notification)
    }
}

private extension SafetyCurtainDoorman {
    func post(notification: Notification.Name) {
        NotificationCenter.default.post(name: notification, object: nil)
    }
}
