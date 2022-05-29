//
//  AppDelegate.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 1/2/21.
//

import UI
import Login
import UIKit
import CoreFoundationLib
import ESCommons
import LoginCommon
import RetailLegacy
import UserNotifications
import CorePushNotificationsService
import Cards

#if APPCENTER
    import AppCenter
    import AppCenterCrashes
#endif
#if COCOADEBUG
    import CocoaDebug
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var legacyAppDelegate: RetailLegacyAppDelegate!
    let appDependencies = AppDependencies()
    var pushNotificationManager: NotificationsHandlerProtocol {
        appDependencies.dependencieEngine.resolve(for: NotificationsHandlerProtocol.self)
    }
    var pushNotificationExecutor: PushNotificationsExecutorProtocol {
        appDependencies.dependencieEngine.resolve(for: PushNotificationsExecutorProtocol.self)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let dependencies = self.appDependencies.dependencieEngine
        let drawer = BaseMenuViewController(legacyResolver: dependencies)
        let moduleDependencies = ModuleDependencies(oldResolver: dependencies, drawer: drawer)
        self.legacyAppDelegate = RetailLegacyAppDelegate(dependenciesEngine: dependencies, coreDependenciesResolver: moduleDependencies, cardExternalDependenciesResolver: moduleDependencies)
        application.applicationSupportsShakeToEdit = false
        self.window = UIWindow()
        self.window?.rootViewController = drawer
        self.window?.makeKeyAndVisible()
        UNUserNotificationCenter.current().delegate = self
        if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            self.pushNotificationManager.registerNotificationReceived(userInfo: remoteNotification, date: Date())
        }
        self.clearBadge()
        self.legacyAppDelegate.application(application, didFinishLaunchingWithOptions: launchOptions)
        AppNavigationDependencies(drawer: drawer, dependenciesEngine: dependencies).registerDependencies()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        self.legacyAppDelegate.applicationWillResignActive(application)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.legacyAppDelegate.applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.legacyAppDelegate.applicationWillEnterForeground(application)
        self.clearBadge()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.legacyAppDelegate.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.legacyAppDelegate.applicationWillTerminate(application)
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.portrait, .landscapeLeft, .landscapeRight]
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return self.legacyAppDelegate.application(app, open: url, options: options)
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let manager = self.appDependencies.dependencieEngine.resolve(forOptionalType: UniversalLinkManagerProtocol.self) {
           return self.shouldContinueUserActivityWith(manager, userActivity: userActivity)
        } else {
            return self.legacyAppDelegate.application(application, continue: userActivity, restorationHandler: restorationHandler)
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.legacyAppDelegate.application(application, performActionFor: shortcutItem, completionHandler: completionHandler)
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotificationManager.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) { 
        self.pushNotificationManager.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func configure() {
        #if COCOADEBUG
        CocoaDebug.enable()
        CocoaDebugSettings.shared.bubbleFrameX = 30
        CocoaDebugSettings.shared.bubbleFrameY = Float(UIScreen.main.bounds.height - 60)
        _CustomHTTPProtocol.setDelegate(self)
        #endif
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        guard self.pushNotificationExecutor.scheduledNotification() == nil else { return }
        self.pushNotificationManager.didReceiveNotificationResponse(response, withCompletionHandler: completionHandler)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.pushNotificationManager.willPresentNotification(notification, withCompletionHandler: completionHandler)
    }
}

// swiftlint:disable identifier_name
#if COCOADEBUG
extension AppDelegate: _CustomHTTPProtocolDelegate {
    func customHTTPProtocol(_ protocol: _CustomHTTPProtocol!, canAuthenticateAgainstProtectionSpace protectionSpace: URLProtectionSpace!) -> Bool {
        return true
    }
    
    func customHTTPProtocol(_ _customHTTPProtocol: _CustomHTTPProtocol!, didCancel challenge: URLAuthenticationChallenge!) {
    }
    
    func customHTTPProtocol(_ _customHTTPProtocol: _CustomHTTPProtocol!, didReceive challenge: URLAuthenticationChallenge!) {
        _customHTTPProtocol.resolve(challenge, with: challenge.protectionSpace.serverTrust.map(URLCredential.init))
    }
}
#endif

private extension AppDelegate {
    func shouldContinueUserActivityWith(_ universalLinkManager: UniversalLinkManagerProtocol, userActivity: NSUserActivity) -> Bool {
        guard let webpageURL = userActivity.webpageURL, userActivity.activityType == NSUserActivityTypeBrowsingWeb else { return false }
        return universalLinkManager.registerUniversalLink(webpageURL)
    }
    
    func clearBadge() {
        self.appDependencies.dependencieEngine.resolve(for: InboxMessagesManager.self).markAllAsRead()
    }
}
