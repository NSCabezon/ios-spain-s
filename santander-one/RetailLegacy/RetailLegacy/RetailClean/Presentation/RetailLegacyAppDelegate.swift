//  Created by Juan Aparicio on 22/11/17.
import UserNotifications
import Localization
import CoreFoundationLib
import UIKit
import UI
import Cards
import CoreDomain

public final class RetailLegacyAppDelegate: UIResponder, UIApplicationDelegate {
    var dependencies: SharedDependencies

    public init(dependenciesEngine: DependenciesResolver & DependenciesInjector, coreDependenciesResolver: RetailLegacyExternalDependenciesResolver, cardExternalDependenciesResolver: CardExternalDependenciesResolver) {
        self.dependencies = SharedDependencies(dependenciesEngine: dependenciesEngine, coreDependenciesResolver: coreDependenciesResolver, cardExternalDependenciesResolver: cardExternalDependenciesResolver)
    }
    
    @discardableResult
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureMetrics()
        
        dependencies.navigatorProvider.appNavigator.presentApp(from: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: StringLoaderNotifications.languageDidChange, object: nil)

        handleOpeningWithOptions(launchOptions)
        
        return true
    }
    
    func loadPublicFiles() {
        dependencies.publicFilesManager.loadPublicFiles(withStrategy: .initialLoad, timeout: 0)
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits
    }
    
    public func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    public func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return dependencies.deepLinkManager.shouldOpenURL(url, options: options)
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return dependencies.userActivityManager.handle(userActivity: userActivity)
    }
    
    public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let performed = handleShortcutItem(shortcutItem)
        completionHandler(performed)
    }
}

// MARK: - Shortcut helpers

private extension RetailLegacyAppDelegate {
    
    @discardableResult private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let deeplink = DeepLink(shortcutItem.type) else {
            return false
        }
        dependencies.deepLinkManager.registerDeepLink(deeplink)
        return true
    }
    
    private func setupForceTouchItems() {
        let provider = self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: ShortcutItemsProviderProtocol.self)
        UIApplication.shared.shortcutItems = provider?.getShortcutItems().map(transformToApplicationShortcutItem)
    }
    
    private func transformToApplicationShortcutItem(from item: ShortcutItemProtocol) -> UIApplicationShortcutItem {
        return UIApplicationShortcutItem(
            type: item.deepLink.deepLinkKey,
            localizedTitle: dependencies.stringLoader.getString(item.localizedTitleKey).text,
            localizedSubtitle: nil,
            icon: item.icon,
            userInfo: nil
        )
    }
    
    @objc private func languageDidChange() {
        setupForceTouchItems()
    }

    private func handleOpeningWithOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let url = launchOptions?[.url] as? URL {
            dependencies.deepLinkManager.shouldOpenURL(url)
        }
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            handleShortcutItem(shortcutItem)
        }
    }
    
    private func configureMetrics() {
        UseCaseWrapper(with: dependencies.useCaseProvider.getMetricsUpdateEnviromentUseCase(), useCaseHandler: dependencies.mainUseCaseHandler)
    }
}
