import UI
import UIKit
import CoreFoundationLib
import UserNotifications
import RetailLegacy
import CorePushNotificationsService
import LoginCommon
#if APPCENTER
    import AppCenter
    import AppCenterCrashes
#endif


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OrientationHandler {
    var window: UIWindow?
    var legacyAppDelegate: RetailLegacyAppDelegate!
    let appDependencies = AppDependencies()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.legacyAppDelegate = RetailLegacyAppDelegate(dependenciesEngine: appDependencies.dependencieEngine, coreDependenciesResolver: self)
            
        application.applicationSupportsShakeToEdit = false
            
        let drawer = BaseMenuViewController(isPrivateSideMenuEnabled: appDependencies.localAppConfig.privateMenu)
        appDependencies.dependencieEngine.register(for: LoginModuleCoordinatorProtocol.self) { dependenciesResolver in
            return LoginModuleCoordinatorMock(navigationController: drawer.navigationController)
        }
        appDependencies.dependencieEngine.register(for: UniversalLinkManagerProtocol.self) { dependenciesResolver in
            return UniversalLinkManagerMock()
        }
        window = UIWindow()
        window?.rootViewController = drawer
        window?.makeKeyAndVisible()
        
        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? AppDelegate

        /** Un comment the lines below to configure appCenter
        #if APPCENTER
        MSAppCenter.start(Compilation.appCenterIdentifier, LowithServices: [MSCrashes.self])
        #endif */
        self.legacyAppDelegate.application(application, didFinishLaunchingWithOptions: launchOptions)
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.legacyAppDelegate.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.legacyAppDelegate.applicationWillTerminate(application)
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return self.legacyAppDelegate.application(app, open: url, options: options)
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return self.legacyAppDelegate.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.legacyAppDelegate.application(application, performActionFor: shortcutItem, completionHandler: completionHandler)
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    // MARK: - Orientation Handler
    
    var orientation: UIInterfaceOrientationMask = .portrait
    var oldOrientation: UIInterfaceOrientationMask?
    
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        self.orientation
    }
    
    // MARK: - Keyboard disallowed in foreground
    public func application(application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: String) -> Bool {
        if extensionPointIdentifier == UIApplication.ExtensionPointIdentifier.keyboard.rawValue {
            return false
        }
        return true
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
}

extension AppDelegate: LegacyCoreDependenciesResolver {
    func resolve() -> GlobalPositionRepository {
        return DefaultGlobalPositionRepository.current
    }
    
    func resolve() -> DependenciesResolver {
        return appDependencies.dependencieEngine
    }
    
    func resolve() -> TrackerManager {
        return appDependencies.dependencieEngine.resolve()
    }
    
    func resolve() -> CoreDependencies {
        return DefaultCoreDependencies()
    }
}
