//
//  PushNotificationConformable.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 28/04/2021.
//

public protocol PushNotificationConformable {
    var id: String { get }
    var title: String { get }
    var message: String { get }
    var date: Date? { get }
    var isRead: Bool { get }
}
