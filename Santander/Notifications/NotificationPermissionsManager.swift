//
//  NotificationPermissionsManager.swift
//  Santander
//
//  Created by alvola on 28/04/2021.
//

import UserNotifications
import UIKit
import CoreFoundationLib
import RetailLegacy

final class NotificationPermissionsManager {
    var completionRegisteredDevice: (() -> Void)?
    private var lastSettings: UNNotificationSettings?
    
    private var isLoggedIn: Bool {
        dependenciesResolver.resolve(for: CoreSessionManager.self).isSessionActive
    }
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependencies: DependenciesResolver) {
        self.dependenciesResolver = dependencies
    }
}

extension NotificationPermissionsManager: PushNotificationPermissionsManagerProtocol {
    func isNotificationsEnabled(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.updateLastSettings(settings) {
                completion(settings.authorizationStatus == .authorized && settings.isAnySettingAvailable)
            }
        }
    }
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (isGranted, error) in
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    guard self.lastSettings != settings,
                          error == nil
                    else { return completion(isGranted) }
                    // we are authorized to use notifications, request a device token for remote notifications
                    guard self.isLoggedIn else { return completion(false) }
                    self.lastSettings = settings
                    UIApplication.shared.registerForRemoteNotifications()
                    completion(isGranted)
                }
            }
        }
    }
    
    func getAuthStatus(completion: @escaping (AuthStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.updateLastSettings(settings) {
                switch settings.authorizationStatus {
                case .authorized:
                    completion(.authorized)
                case .notDetermined, .denied, .provisional, .ephemeral:
                    completion(.denied)
                @unknown default:
                    completion(.denied)
                }
            }
        }
    }
    
    func isAlreadySet(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.updateLastSettings(settings) {
                DispatchQueue.main.async {
                    completion(settings.authorizationStatus != .notDetermined)
                }
            }
        }
    }
    
    func checkAccess(_ completion: (() -> Void)? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized && settings.isAnySettingAvailable
            else {
                completion?()
                return
            }
            self?.completionRegisteredDevice = completion
            self?.requestAccess { _ in }
        }
    }
}

private extension NotificationPermissionsManager {
    func updateLastSettings(_ settings: UNNotificationSettings, _ completion: (() -> Void)? = nil) {
        guard lastSettings == nil
        else {
            lastSettings = settings
            completion?()
            return
        }
        checkAccess(completion)
    }
}
