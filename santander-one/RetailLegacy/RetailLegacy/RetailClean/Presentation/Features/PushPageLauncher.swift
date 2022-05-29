//
//  PushPageLauncher.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 9/23/20.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

protocol PushPageLauncher {
    var presenterProvider: PresenterProvider { get }
    var navigatorProvider: NavigatorProvider { get }
    var deepLinkManager: DeepLinkManager { get }
    var stringLoader: StringLoader { get }
    var trackerManager: TrackerManager { get }
    func goToDeeplink(deepLink: DeepLink?)
    func goToExternalURL(url: String)
    func goToWebView(webViewConfig: PushNotificationsWebViewConfiguration)
    func goToShowDialog(title: String?, message: String?, completion: (() -> Void)?)
    func goToLandingPush(cardTransactionInfo: CardTransactionPush?, cardAlertInfo: CardAlertPush?)
}

extension PushPageLauncher {
    func goToLandingPush(cardTransactionInfo: CardTransactionPush?, cardAlertInfo: CardAlertPush?) {
        guard navigatorProvider.landingPushLauncherNavigator.drawer.presentingViewController == nil, navigatorProvider.landingPushLauncherNavigator.drawer.presentedViewController == nil, navigatorProvider.landingPushLauncherNavigator.drawer.isSideMenuVisible == false else {
            return
        }
        navigatorProvider.landingPushLauncherNavigator.launchLandingPush(cardTransactionInfo: cardTransactionInfo, cardAlertInfo: cardAlertInfo)
    }
    
    func goToGenericLandingPush(accountTransactionInfo: AccountLandingPushData) {
        guard navigatorProvider.landingPushLauncherNavigator.drawer.presentingViewController == nil, navigatorProvider.landingPushLauncherNavigator.drawer.presentedViewController == nil, navigatorProvider.landingPushLauncherNavigator.drawer.isSideMenuVisible == false else {
            return
        }
        navigatorProvider.landingPushLauncherNavigator.genericLaunchLandingPush(accountTransactionInfo: accountTransactionInfo)
    }
    
    func goToDeeplink(deepLink: DeepLink?) {
        guard let deepLink = deepLink else { return }
        deepLinkManager.registerDeepLink(deepLink)
    }
    
    func goToExternalURL(url: String) {
        navigatorProvider.privateHomeNavigator.open(url: url)
    }
    
    func goToWebView(webViewConfig: PushNotificationsWebViewConfiguration) {
        guard let presentationComponent = presenterProvider.dependencies else { return }
        navigatorProvider.appNavigator.goToWebView(with: webViewConfig, linkHandler: nil, dependencies: presentationComponent, errorHandler: nil, didCloseClosure: nil)
    }
    
    func goToShowDialog(title: String?, message: String?, completion: (() -> Void)?) {
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: completion)
        let cancel = DialogButtonComponents(titled: stringLoader.getString("generic_button_cancel"), does: nil)
        let titleMessage: LocalizedStylableText
        if let title = title, title.isNotEmpty {
            titleMessage = LocalizedStylableText(text: title, styles: nil)
        } else {
            titleMessage = stringLoader.getString("notificationMailbox_label_santander")
        }
        let bodyMessage: LocalizedStylableText
        if let message = message, message.isNotEmpty {
            bodyMessage = LocalizedStylableText(text: message, styles: nil)
        } else {
            bodyMessage = .empty
        }
        
        navigatorProvider.appNavigator.showDialogOnDrawer(title: titleMessage, body: bodyMessage, acceptButton: accept, cancelButton: cancel)
    }
}
