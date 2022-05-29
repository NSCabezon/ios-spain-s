//
//  CorePushNavigatorProviderDelegate.swift
//  CorePushNotificationsService
//
//  Created by Alvaro Royo on 29/4/21.
//

import CoreFoundationLib

public protocol CorePushNavigatorProviderDelegate: AnyObject {
    func goToShowDialog(title: String?, message: String?, completion: (() -> Void)?)
    func goToExternalURL(url: String)
    func goToWebView(with url: String, title: String)
    func goToLandingPush(cardTransactionInfo: CardTransactionPush?, cardAlert: CardAlertPush?)
    func goToGenericLandingPush(accountTransactionInfo: AccountLandingPushDataBridge)
}
