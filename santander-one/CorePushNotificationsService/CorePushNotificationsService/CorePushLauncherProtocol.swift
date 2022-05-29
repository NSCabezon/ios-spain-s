//
//  CorePushLauncher.swift
//  CorePushNotificationsService

import Foundation
import CoreFoundationLib

protocol CorePushLauncherProtocol {
    var deepLinkManager: DeepLinkManagerProtocol { get }
    func goToDeeplink(deepLink: DeepLinkEnumerationCapable?)
    func goToExternalURL(url: String)
    func goToWebView(webViewConfig: PushWebviewSettings)
    func goToShowDialog(title: String?, message: String?, completion: (() -> Void)?)
    func goToLandingPush(cardTransactionInfo: CardTransactionPush?, cardAlert: CardAlertPush?)
}
