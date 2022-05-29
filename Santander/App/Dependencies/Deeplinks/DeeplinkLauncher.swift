//
//  DeeplinkLauncher.swift
//  Santander
//
//  Created by Francisco del Real Escudero on 13/4/21.
//

import CoreFoundationLib
import Ecommerce
import RetailLegacy
import Bizum

struct DeeplinkLauncher {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension DeeplinkLauncher: CustomDeeplinkLauncher {
    func launch(deeplink: String, with userInfo: [DeepLinkUserInfoKeys: String]) {
        guard let spainDeeplink = SpainDeepLink(deeplink, userInfo: userInfo) else { return }
        self.launch(spainDeepLink: spainDeeplink)
    }
    
    func launch(deeplink: DeepLinkEnumerationCapable) {
        guard let spainDeeplink = deeplink as? SpainDeepLink else { return }
        self.launch(spainDeepLink: spainDeeplink)
    }
}

private extension DeeplinkLauncher {
    func launch(spainDeepLink: SpainDeepLink) {
        switch spainDeepLink {
        case .ecommerce:
            dependenciesResolver.resolve(for: EcommerceNavigatorProtocol.self).showEcommerce(.mainPushNotification)
        case .bizum:
            dependenciesResolver.resolve(for: BizumStartCapable.self).launchBizum()
        }
    }
}
