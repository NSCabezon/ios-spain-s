//
//  CorePushLauncher.swift
//  CorePushNotificationsService

import CoreFoundationLib

public protocol CustomPushLauncherProtocol {
    func executeActionForType(actionType: CustomPushLaunchActionTypeCapable)
}

final class CorePushLauncher {
    private let dependencies: DependenciesResolver
    var deepLinkManager: DeepLinkManagerProtocol
    weak var navigatorProviderDelegate: CorePushNavigatorProviderDelegate?

    // MARK: - Public methods
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
        deepLinkManager = dependencies.resolve(for: DeepLinkManagerProtocol.self)
        navigatorProviderDelegate = dependencies.resolve(for: CorePushNavigatorProviderDelegate.self)
    }
    
    func executeActionForType(_ actionType: PushLaunchActionType) {
        switch actionType {
        case .webview(let webviewSettings):
            goToWebView(webViewConfig: webviewSettings)
        case .dialog(let dialogSettings):
            goToShowDialog(title: dialogSettings.title, message: dialogSettings.message) {
                self.goToDeeplink(deepLink: dialogSettings.postDeepLinkNavigation)
            }
        case .extUrl(let url):
            goToExternalURL(url: url)
        case .cardTransaction(let transaction, let alert):
            goToLandingPush(cardTransactionInfo: transaction, cardAlert: alert)
        case .accountTransaction(let transaction, let alert):
            goToGenericLandingPush(accountTransactionPush: transaction, cardAlert: alert)
        case .deeplink(let deepLink):
            goToDeeplink(deepLink: deepLink)
        case .custom(let customAction):
            let customLauncher = self.dependencies.resolve(forOptionalType: CustomPushLauncherProtocol.self)
            customLauncher?.executeActionForType(actionType: customAction)
        }
    }
}

extension CorePushLauncher: CorePushLauncherProtocol {
    
    func goToDeeplink(deepLink: DeepLinkEnumerationCapable?) {
        guard let deepLink = deepLink else { return }
        deepLinkManager.registerDeepLink(deepLink)
    }
    
    func goToShowDialog(title: String?, message: String?, completion: (() -> Void)?) {
        navigatorProviderDelegate?.goToShowDialog(title: title, message: message, completion: completion)
    }
    
    func goToExternalURL(url: String) {
        navigatorProviderDelegate?.goToExternalURL(url: url)
    }

    func goToWebView(webViewConfig: PushWebviewSettings) {
        navigatorProviderDelegate?.goToWebView(with: webViewConfig.url, title: webViewConfig.title)
    }

    func goToLandingPush(cardTransactionInfo: CardTransactionPush?, cardAlert: CardAlertPush?) {
        navigatorProviderDelegate?.goToLandingPush(cardTransactionInfo: cardTransactionInfo, cardAlert: cardAlert)
    }
    
    func goToGenericLandingPush(accountTransactionPush: AccountTransactionPushProtocol?, cardAlert: CardAlertPush?) {
        guard let accountTransactionPush = accountTransactionPush,
              let cardAlert = cardAlert
        else { return }
        let bridgedInfo = AccountLandingPushDataBridge(
            accountTransactionInfo: accountTransactionPush,
            alertInfo: cardAlert,
            dependenciesResolver: self.dependencies
        )
        navigatorProviderDelegate?.goToGenericLandingPush(accountTransactionInfo: bridgedInfo)
    }
}
