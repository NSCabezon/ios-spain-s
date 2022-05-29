//
//  InboxServiceInjector.swift
//  Inbox
//
//  Created by Carlos Monfort Gómez on 9/9/21.
//

import CoreTestData
import QuickSetup

public final class InboxServiceInjector: CustomServiceInjector {
    public init() {}
    public func inject(injector: MockDataInjector) {
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
        injector.register(
            for: \.pullOffersConfig.getPullOffersConfig,
            filename: "pull_offers_configV4_without_cushion"
        )
        injector.register(
            for: \.appConfigLocalData.getAppConfigLocalData,
            filename: "app_config_v2"
        )
        injector.register(
            for: \.authData.loginTouchId,
            filename: "loginTouchId"
        )
        injector.register(
            for: \.authData.tryOauthLogin,
            filename: "tryOauthLogin"
        )
        injector.register(
            for: \.authData.getAuthCredentials,
            filename: "getAuthCredentials"
        )
        injector.register(
            for: \.pendingSolicitudes.getPendingSolicitudes,
            filename: "getPendingSolicitudes"
        )
    }
}
