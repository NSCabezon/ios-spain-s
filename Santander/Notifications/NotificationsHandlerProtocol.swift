//
//  NotificationsHandlerProtocol.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 15/04/2021.
//
import Foundation
import CoreFoundationLib
import RetailLegacy

public typealias NotificationServiceProtocol = NotificationServiceCapable & NotificationResponseCapable

// MARK: - NotificationResponseCapable

public protocol NotificationResponseCapable {
    
    /// NotificationManager call this method once received from UNNotificationCenter willPresentNotification message
    /// - Parameters:
    ///   - info: fully parsed notification info
    ///   - completionHandler: block to invoque after process notification, it must specify how the system should alert the user about notification. Ex. [.badge, .sound]
    func willPresentPushWIthInfo(_ info: SPPushNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    
    /// NotificationManager call this method once received from UNNotificationCenter didReceiveNotificationResponse
    /// - Parameters:
    ///   - info: fully parsed notification info
    ///   - completionHandler: <#completionHandler description#>
    func didReceive(_ info: SPPushNotification, withCompletionHandler completionHandler: @escaping () -> Void)
}

// MARK: - NotificationServiceCapable

/// All services that will handle NotificationManager will be conforming this type
public protocol NotificationServiceCapable {
    func start()
    
    /// Register as object capable of ask/forward messages to CoreNotifications throught delegate. You should not call this method directly. NotificationManager will do it once added a service
    /// - Parameter delegate: an object conforming to notificationProcessor
    func setProcessorDelegate(_ delegate: NotificationProcessorProtocol)
    
    /// The identifier for the service, its a good practice declare in Constans file. none of the identifiers
    var serviceIdentifier: String { get }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data)
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error)
}

/// Declare an interface that will handle all events from AppDelegate related to push registration/receive
public protocol NotificationManagerServiceCapable {
    
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data)
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error)
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any])
    
    func registerNotificationReceived(userInfo: [AnyHashable: Any], date: Date)
}

// MARK: - NotificationsHandlerProtocol
public protocol NotificationsHandlerProtocol: NotificationManagerServiceCapable & NotificationProcessorProtocol {
    
    /// Add a service to NotificationManager instance. Trying to add a service with the same identifier replace the current value for the one being added.
    /// - Parameter notificationService: and instance of an object conforming to this protocol
    @discardableResult
    func addService(_ notificationService: NotificationServiceProtocol) -> NotificationsManager
    
    /// Retrieve from the services stack a registered instance with the provided identifier
    /// - Parameter identifier: service identifier
    func serviceWithIdentifier(_ identifier: String) -> NotificationServiceProtocol?
        
    /// print on console registered services class names.
    func registeredServices() -> [String]?
    
    /// Handle a notification that arrived while the app was running in the foreground.
    /// - Parameters:
    ///   - notification: UNNotification object
    ///   - completionHandler: You must execute this block at some point after processing the user's response to let the system know that you are done
    func willPresentNotification(_ notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    
    /// you can take whatever actions are necessary to process the notification and update your app. When you finish, call the completionHandler block and specify how you want the system to alert the user, if at all.
    /// - Parameters:
    ///   - response: UNNotificationResponse
    ///   - completionHandler: the block that will call particular service implementation
    func didReceiveNotificationResponse(_ response: UNNotificationResponse,
                                        withCompletionHandler completionHandler: @escaping () -> Void)
}
