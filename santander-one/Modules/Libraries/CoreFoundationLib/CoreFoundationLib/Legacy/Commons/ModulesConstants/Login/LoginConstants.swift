//
//  File.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/23/20.
//

import Foundation

public enum LoginConstants {
    public static let appConfigActiveMessage = "inactiveMessage"
    public static let appConfigRecoverKeysUrl = "recoverKeysUrl"
    public static let appConfigObtainKeysUrl = "obtainKeysUrl"
    public static let appConfigActive = "active"
    public static let loginOk = "Login_OK"
    public static let forceUpdateKeys = "forceUpdateKeys"
    public static let enabledTrusteer = "enableTrusteer"
}

public enum UnrememberedLoginPullOffers {
    public static let publicTutorial = "PUBLIC_TUTORIAL"
}

public struct UnrememberedLoginPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/login/unknown_user"
    public enum Action: String {
        case userLocation = "get_location"
        case internalLogin = "login_attempt"
        case error = "error_{step1_step2}"
    }
    public init() {}
}

public enum LoginRememberedPullOffers {
    public static let publicTutorialRec = "PUBLIC_TUTORIAL_REC"
}

public struct LoginRememberedPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/login/known_user"
    public enum Action: String {
        case internalLogin = "login_attempt"
        case userLocation = "get_location"
        case error = "error_{step1_step2}"
        case ecommerceButton = "santander_key"
    }
    public init() {}
}
