//
//  SalesForceHandler.swift
//  RetailClean
//
//  Created by Luis Escámez Sánchez on 18/01/2021.
//  Copyright © 2021 Ciber. All rights reserved.
//

import MarketingCloudSDK
import Foundation
import Inbox
import CoreFoundationLib
import RetailLegacy
import ESCommons

class SalesForceHandler {
    private var completion: (([PushNotification]?) -> Void)?
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.setup()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(completeRefreshInbox),
                                               name: .refreshComplete,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .refreshComplete, object: nil)
    }
}

extension SalesForceHandler: SalesForceHandlerProtocol {
    func setContactKey(_ contactKey: String) {
        shared.sfmc_setContactKey(contactKey)
    }
    
    func register(_ deviceToken: Data) {
        shared.sfmc_setDeviceToken(deviceToken)
    }
    
    func setNotificationRequest(_ request: UNNotificationRequest) {
        shared.sfmc_setNotificationRequest(request)
    }
    
    func getUserInbox(completion: @escaping(_ list: [PushNotification]?) -> Void) {
        if shared.sfmc_refreshMessages() == false {
            completion(receiveInbox())
        } else {
            self.completion = completion
        }
    }
    
    @objc func completeRefreshInbox(notification: NSNotification) {
        if notification.name == .refreshComplete {
            guard let completion = self.completion else {
                return
            }
            completion(receiveInbox())
        }
    }
    
    func markAsRead(notification: PushNotification) {
        guard let notificationToMarkAsRead = findNotification(notificationToFind: notification) else { return }
        shared.sfmc_markMessageRead(notificationToMarkAsRead)
    }
    
    func markAllAsRead() {
        shared.sfmc_markAllMessagesRead()
    }
    
    func delete(notification: PushNotification) {
        guard let notificationToRemove = findNotification(notificationToFind: notification) else { return }
        shared.sfmc_markMessageDeleted(notificationToRemove)
    }
    
    func deleteAll() {
        shared.sfmc_markAllMessagesDeleted()
    }
}

private extension SalesForceHandler {
    var shared: MarketingCloudSDK {
        return MarketingCloudSDK.sharedInstance()
    }
    var notifications: [Any] {
        var finalNotifications: [Any] = []
        
        guard let notifications = shared.sfmc_getAllMessages() else {
            return []
        }
        
        for case let notification as [String: AnyObject] in notifications {
            guard
                let subscriber = findByKeyInKeysNotification(notification: notification, keyToFind: "subscriber") as? String,
                let userId = getContactKey(),
                userId == subscriber else {
                continue
            }
            finalNotifications.append(notification)
        }
        return finalNotifications
    }
    var timeManager: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    var stringLoader: StringLoader  {
        return self.dependenciesResolver.resolve(for: StringLoader.self)
    }
    
    func createDictionarySetup() -> [AnyHashable: Any]? {
        let password = DomainConstant.K2 + DomainConstant.K0 + DomainConstant.K1
        let marketingCloudSDKBuilder = MarketingCloudSDKConfigBuilder()
        let compilation: CompilationProtocol = self.dependenciesResolver.resolve(for: CompilationProtocol.self)
        guard
            let appID = compilation.salesForceAppId.decrypt(keyString: password),
            let accessToken = compilation.salesForceAccessToken.decrypt(keyString: password),
            let cloudServerUrl = "OkhGaTtWwRfE4280nvK+iPCLjXTeg6TEI6+CgJvF9cAzGgnInWNO+B3PeDLM8tcmzCRydmnHOfWIABK99hDyr2DCHVn5kjQjn8zzfgPd0MA=".decrypt(keyString: password),
            let mid = compilation.salesForceMid.decrypt(keyString: password) else {
            return nil
        }
        marketingCloudSDKBuilder.sfmc_setApplicationId(appID)
        marketingCloudSDKBuilder.sfmc_setAccessToken(accessToken)
        marketingCloudSDKBuilder.sfmc_setMarketingCloudServerUrl(cloudServerUrl)
        marketingCloudSDKBuilder.sfmc_setMid(mid)
        marketingCloudSDKBuilder.sfmc_setAnalyticsEnabled(true)
        marketingCloudSDKBuilder.sfmc_setPiAnalyticsEnabled(true)
        marketingCloudSDKBuilder.sfmc_setLocationEnabled(false)
        marketingCloudSDKBuilder.sfmc_setInboxEnabled(true)
        //TODO: Rollback MarketingCloudSDK from 6.2.3 to 6.0.1
        marketingCloudSDKBuilder.sfmc_setUseLegacyPIIdentifier(true)
        marketingCloudSDKBuilder.sfmc_setApplicationControlsBadging(false)
        
        return marketingCloudSDKBuilder.sfmc_build()
    }
    
    func setup() {
        do {
            guard let setupDictionary = createDictionarySetup() else { return }
            try shared.sfmc_configure(with: setupDictionary, completionHandler: { [weak self] (success, _, _) in
                // The SDK has been fully configured and is ready for use!
                if success == true {
                    // turn on logging for debugging.  Not recommended for production apps.
                    self?.shared.sfmc_setDebugLoggingEnabled(Compilation.isLogEnabled)
                }
            })
        } catch let error as NSError {
            print("Error: \(error)")
        }
    }
    
    func getContactKey() -> String? {
        return shared.sfmc_contactKey()
    }
    
    func receiveInbox() -> [PushNotification] {
        var listNotifications: [PushNotification] = []
        for case let notification as [String: AnyObject] in notifications {
            guard
                let id = notification["id"] as? String,
                let message = notification["subject"] as? String,
                let read = notification["read"] as? Bool else {
                return []
            }
            
            let stringDate = findByKeyInKeysNotification(notification: notification, keyToFind: "customInboxDate") as? String ?? ""
            let date = timeManager.fromString(input: stringDate, inputFormat: TimeFormat.yyyy_MM_ddHHmmss)
            let new = PushNotification(id: id,
                                       title: notification["title"] as? String ?? stringLoader.getString("notificationMailbox_label_santander").plainText ?? "",
                                       message: notification["alert"] as? String ?? message,
                                       date: date,
                                       isRead: read,
                                       type: .salesforce)
            listNotifications.append(new)
        }
        return listNotifications.sorted(by: { ($0.date ?? Date()).compare($1.date ?? Date()) == .orderedDescending })
    }
    
    func findNotification(notificationToFind: PushNotification) -> [String: AnyObject]? {
        for case let notification as [String: AnyObject] in notifications {
            guard let id = notification["id"] as? String else { return nil }
            if id == notificationToFind.id {
                return notification
            }
        }
        return nil
    }
    
    func findByKeyInKeysNotification(notification: [String: AnyObject], keyToFind: String) -> Any? {
        guard let keysDictionary = notification["keys"] as? NSMutableArray else {
            return nil
        }
        for case let element as NSDictionary in keysDictionary {
            guard let key = element["key"] as? String else {
                return nil
            }
            if key == keyToFind {
                return element["value"]
            }
        }
        return nil
    }
}

extension Notification.Name {
    static let refreshComplete = Notification.Name("SFMCInboxMessagesRefreshCompleteNotification")
}

extension SalesForceHandler: PushNotificationManagerProtocol {
    func markAsRead(notification: PushNotificationEntity) {
        let noti = PushNotification.toPushNotificationSalesforce(notification: notification)
        self.markAsRead(notification: noti)
    }
    
    func getUserInboxBridge(completion: @escaping(_ list: [PushNotificationEntity]?) -> Void) {
        self.getUserInbox { notifications in
            guard let noti = notifications else { return completion(nil) }
            completion(noti.map { $0.toPushNotificationEntity() })
        }
    }
    
    func delete(notification: PushNotificationEntity) {
        let noti = PushNotification.toPushNotificationSalesforce(notification: notification)
        self.delete(notification: noti)
    }
}
