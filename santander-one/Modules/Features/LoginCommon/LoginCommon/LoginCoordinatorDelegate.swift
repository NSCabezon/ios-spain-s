//
//  LoginCoordinatorDelegate.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/3/20.
//

import Foundation
import CoreDomain
import CoreFoundationLib
import CoreDomain

public protocol LoginCoordinatorDelegate: AnyObject {
    func goToFakePrivate(isPb: Bool, name: String?)
    func backToLogin()
    func goToPrivate(globalPositionOption: GlobalPositionOptionEntity)
    func goToOtpSca(username: String, isFirstTime: Bool)
    func reloadSideMenu()
    func didSelectOffer(_ offer: OfferEntity)
    func goToEnvironmentsSelector(completion: @escaping () -> Void)
    func didSelectMenu()
    func goToUrl(urlString: String)
    func registerSecuritySettingsDeepLink()
    func goToPublic(shouldGoToRememberedLogin: Bool)
    func goToQuickBalance()
    func deleteSiriIntents()
}
