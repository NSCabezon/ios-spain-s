//
//  PushNotificationPermissionsManagerMock.swift
//  PersonalArea
//
//  Created by Juan Jose Acosta González on 10/9/21.
//

import CoreFoundationLib

public final class PushNotificationPermissionsManagerProtocolMock: PushNotificationPermissionsManagerProtocol {
    public var completionRegisteredDevice: (() -> Void)?
    
    public init() {}
    
    public func getAuthStatus(completion: @escaping (AuthStatus) -> Void) {
        completion(.authorized)
    }
    
    public func checkAccess(_ completion: (() -> Void)?) {
        completion?()
    }
    
    public func isNotificationsEnabled(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    public func requestAccess(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    public func isAlreadySet(_ completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}
