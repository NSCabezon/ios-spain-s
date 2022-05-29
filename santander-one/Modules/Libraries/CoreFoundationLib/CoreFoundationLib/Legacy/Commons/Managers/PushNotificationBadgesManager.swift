//
//  PushNotificationBadgesManager.swift
//  Commons
//
//  Created by Alvaro Royo on 10/5/21.
//

import Foundation

public protocol PushNotificationBadgesManagerProtocol: AnyObject {
    func increaseBadge()
    func decreaseBadge()
    func clearBadges()
    func getBadge() -> Int
}

public extension PushNotificationBadgesManagerProtocol {
    var badge: Int {
        get { UIApplication.shared.applicationIconBadgeNumber }
        set { UIApplication.shared.applicationIconBadgeNumber = newValue }
    }
    
    func increaseBadge() {
        badge += 1
    }
    
    func decreaseBadge() {
        badge -= 1
    }
    
    func clearBadges() {
        badge = 0
    }
    
    func getBadge() -> Int {
        badge
    }
    
}
