//
//  NavigatorProvider+CorePushNotificationProviderDelegate.swift
//  Santander
//
//  Created by Alvaro Royo on 29/4/21.
//

import CoreFoundationLib
import Foundation
import RetailLegacy
import CorePushNotificationsService

extension NavigatorProvider: CorePushNavigatorProviderDelegate {
    public func goToShowDialog(title: String?, message: String?, completion: (() -> Void)?) {
        showDialog(title: title, message: message, completion: completion)
    }
    
    public func goToExternalURL(url: String) {
        open(url: url)
    }
    
    public func goToWebView(with url: String, title: String) {
        openWebView(with: url, title: title)
    }
    
    public func goToLandingPush(cardTransactionInfo: CardTransactionPush?, cardAlert: CardAlertPush?) {
        openLandingPush(cardTransactionInfo: cardTransactionInfo, cardAlertInfo: cardAlert)
    }
    
    public func goToGenericLandingPush(accountTransactionInfo: AccountLandingPushDataBridge) {
        openGenericLandingPush(accountTransactionInfo: accountTransactionInfo)
    }
}
