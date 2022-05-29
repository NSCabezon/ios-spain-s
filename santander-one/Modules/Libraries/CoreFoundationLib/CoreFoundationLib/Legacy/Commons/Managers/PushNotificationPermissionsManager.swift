//
//  PushNotificationPermissionsManager.swift
//  Commons
//
//  Created by alvola on 28/11/2019.
//

public enum AuthStatus {
    case authorized
    case denied
}

public protocol PushNotificationPermissionsManagerProtocol: AnyObject {
    var completionRegisteredDevice: (() -> Void)? { get set }
    
    func isNotificationsEnabled(completion: @escaping (Bool) -> Void)
    func requestAccess(completion: @escaping (Bool) -> Void)
    func isAlreadySet(_ completion: @escaping (Bool) -> Void)
    func getAuthStatus(completion: @escaping (AuthStatus) -> Void)
    func checkAccess(_ completion: (() -> Void)?)
}

public extension PushNotificationPermissionsManagerProtocol {
    func callCompletionRegisterDeviceAndClean() {
        self.completionRegisteredDevice?()
        self.completionRegisteredDevice = nil
    }
}
