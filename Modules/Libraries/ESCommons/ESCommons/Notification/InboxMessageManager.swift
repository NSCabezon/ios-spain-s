//
//  InboxMessageManager.swift
//  ESCommons
//
//  Created by José María Jiménez Pérez on 10/6/21.
//
import CoreFoundationLib

public protocol InboxMessagesManager {
    func markAllAsRead()
    func markAsRead(notification: PushNotificationConformable)
    func getUserInbox(completion: @escaping(_ list: [PushNotificationConformable]?) -> Void)
    func delete(notification: [PushNotificationConformable], completion: @escaping(Bool) -> Void)
    func deleteAll()
    func setSubscriberKey()
}
