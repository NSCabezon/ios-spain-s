//
//  SalesforceHandler.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 14/04/2021.
//

import CoreFoundationLib
import MarketingCloudSDK
import RetailLegacy
import ESCommons

public final class SalesforceHandlerSP {
    private var receiveInboxCompletion: (([PushNotification]?) -> Void)?
    private let dependenciesResolver: DependenciesResolver
    private let sharedInstance: MarketingCloudSDK = MarketingCloudSDK.sharedInstance()
    private weak var notificationProcessorDelegate: NotificationProcessorProtocol?
    private var notificationReceived: SPPushNotification?

    private lazy var deleteMessageUseCase: DeleteSalesForceInboxMessagesUseCaseUseCase = {
        DeleteSalesForceInboxMessagesUseCaseUseCase()
    }()
    
    required init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        NotificationCenter.default.addObserver(forName: .inboxRefreshComplete,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            self?.completeRefreshInbox()
        }
    }
}

// MARK: - SPSalesForceHandlerProtocol

extension SalesforceHandlerSP: SPSalesForceHandlerProtocol {
    public func delete(notification: [PushNotificationConformable], completion: @escaping(Bool) -> Void) {
        let notificationToDelete = notification.compactMap({findNotification(notificationToFind: $0)})
        let input = DeleteSalesForceInboxMessagesUseCaseUseCaseInput(notifications: notificationToDelete)
        Scenario(useCase: deleteMessageUseCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { _ in
                completion(true)
            }
            .onError { _ in
                completion(false)
            }
    }
        
    public func markAsRead(notification: PushNotificationConformable) {
        guard let notificationToMarkAsRead = findNotification(notificationToFind: notification) else { return }
        sharedInstance.sfmc_markMessageRead(notificationToMarkAsRead)
        self.notificationProcessorDelegate?.decrementBadge()
    }
        
    public func getUserInbox(completion: @escaping ([PushNotificationConformable]?) -> Void) {
        if sharedInstance.sfmc_refreshMessages() == false {
            let elements = self.receiveInbox()
            completion(elements)
        } else {
            self.receiveInboxCompletion = completion
        }
    }
    
    public func start() {
        self.setup()
    }
    
    public func setProcessorDelegate(_ delegate: NotificationProcessorProtocol) {
        self.notificationProcessorDelegate = delegate
    }

    public var serviceIdentifier: String {
        return ServiceIdentifier.salesforce
    }
    
    public func markAllAsRead() {
        sharedInstance.sfmc_markAllMessagesRead()
        self.notificationProcessorDelegate?.clearAllBadges()
    }
    
    func getInbox(completion: @escaping ([PushNotification]?) -> Void) {
        if sharedInstance.sfmc_refreshMessages() == false {
            let elements = self.receiveInbox()
            completion(elements)
        } else {
            self.receiveInboxCompletion = completion
        }
    }
    
    public func deleteAll() {
        sharedInstance.sfmc_markAllMessagesDeleted()
    }
    
    public func setSubscriberKey() {
        registerSalesForceInfoUser()
    }
    
    // NotificationServiceCapable
    public func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        self.sharedInstance.sfmc_setDeviceToken(deviceToken)
    }
    public func registerDeviceToken(_ deviceToken: Data) {
        self.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    public func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {}
}

extension SalesforceHandlerSP: NotificationResponseCapable {
    public func willPresentPushWIthInfo(_ info: SPPushNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    public func didReceive(_ info: SPPushNotification, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = info.userInfo
        if userInfo["_sid"] != nil {
            switch info.systemNotification {
            case let .response(notificationResponse):
                self.sharedInstance.sfmc_setNotificationRequest(notificationResponse.notification.request)
                self.sharedInstance.sfmc_markAllMessagesRead()

            default:
                return
            }
        }
        self.notificationProcessorDelegate?.handleNotification(info)
        completionHandler()
    }
}

private extension SalesforceHandlerSP {
    func registerSalesForceInfoUser() {
        let useCase = GetUserInfoUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] (result) in
                guard
                    let userId = result.userId,
                    !userId.isEmpty,
                    userId != self?.sharedInstance.sfmc_contactKey()
                else { return }
                self?.sharedInstance.sfmc_setContactKey(userId)
            }
    }
    
    func receiveInbox() -> [PushNotification] {
        var listNotifications: [PushNotification] = []
        for case let notification as [String: AnyObject] in notifications {
            guard
                let notificationId = notification["id"] as? String,
                let message = notification["subject"] as? String,
                let read = notification["read"] as? Bool else {
                return []
            }
            
            let stringDate = findByKeyInKeysNotification(notification: notification, keyToFind: "customInboxDate") as? String ?? ""
            let date = dateFromString(input: stringDate, inputFormat: .yyyy_MM_ddHHmmss)
            let new = PushNotification(id: notificationId,
                                       title: notification["title"] as? String ?? localized("notificationMailbox_label_santander"),
                                       message: notification["alert"] as? String ?? message,
                                       date: date,
                                       isRead: read,
                                       type: .salesforce)
            listNotifications.append(new)
        }
        return listNotifications.sorted(by: { ($0.date ?? Date()).compare($1.date ?? Date()) == .orderedDescending })
    }
}

// MARK: - sdk initialization
private extension SalesforceHandlerSP {
    var compilation: SpainCompilationProtocol {
        self.dependenciesResolver.resolve()
    }

    var notifications: [Any] {
        var finalNotifications: [Any] = []
        guard let notifications = sharedInstance.sfmc_getAllMessages() else {
            return []
        }
        for case let notification as [String: AnyObject] in notifications {
            guard
                let subscriber = findByKeyInKeysNotification(notification: notification, keyToFind: "subscriber") as? String,
                let userId = sharedInstance.sfmc_contactKey(),
                userId == subscriber else {
                continue
            }
            finalNotifications.append(notification)
        }
        return finalNotifications
    }
    
    var setupdictionary: [AnyHashable: Any]? {
        let password = DomainConstant.K2 + DomainConstant.K0 + DomainConstant.K1
        let sdkBuilder = MarketingCloudSDKConfigBuilder()
        guard
            let appID = compilation.salesForceAppId.decrypt(keyString: password),
            let accessToken = compilation.salesForceAccessToken.decrypt(keyString: password),
            let cloudServerUrl = compilation.salesForceEndPoint.decrypt(keyString: password),
            let mid = compilation.salesForceMid.decrypt(keyString: password) else { return nil }
        sdkBuilder.sfmc_setApplicationId(appID)
        sdkBuilder.sfmc_setAccessToken(accessToken)
        sdkBuilder.sfmc_setMarketingCloudServerUrl(cloudServerUrl)
        sdkBuilder.sfmc_setMid(mid)
        sdkBuilder.sfmc_setAnalyticsEnabled(true)
        sdkBuilder.sfmc_setPiAnalyticsEnabled(true)
        sdkBuilder.sfmc_setLocationEnabled(false)
        sdkBuilder.sfmc_setInboxEnabled(true)
        sdkBuilder.sfmc_setUseLegacyPIIdentifier(true)
        sdkBuilder.sfmc_setApplicationControlsBadging(true)
        return sdkBuilder.sfmc_build()
    }
    
    func setup() {
        guard let setupDictionary = setupdictionary else { return }
        do {
            try sharedInstance.sfmc_configure(with: setupDictionary,
                                              completionHandler: { [weak self] (success, _, _) in
                if success == true {
                    self?.sharedInstance.sfmc_setDebugLoggingEnabled(self?.compilation.isLogEnabled ?? false)
                }
            })
        } catch let error as NSError {
            print("Error: \(error)")
        }
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
    
    func findNotification(notificationToFind: PushNotificationConformable) -> [String: AnyObject]? {
        for case let notification as [String: AnyObject] in notifications {
            guard let notificationId = notification["id"] as? String else { return nil }
            if notificationId == notificationToFind.id {
                return notification
            }
        }
        return nil
    }
    
    @objc func completeRefreshInbox() {
        guard let completion = self.receiveInboxCompletion else {
            return
        }
        completion(receiveInbox())
        self.receiveInboxCompletion = nil
    }
}

extension Notification.Name {
    static let inboxRefreshComplete = Notification.Name("SFMCInboxMessagesRefreshCompleteNotification")
    static let newMessages = Notification.Name("SFMCInboxMessagesNewInboxMessagesNotification")
}
