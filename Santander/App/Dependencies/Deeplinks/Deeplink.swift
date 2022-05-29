//
//  ESDeeplink.swift
//  Santander
//
//  Created by Francisco del Real Escudero on 13/4/21.
//

import CoreFoundationLib

enum SpainDeepLink {
    case ecommerce
    case bizum
}

extension SpainDeepLink: DeepLinkEnumerationCapable {
    init?(_ string: String, userInfo: [DeepLinkUserInfoKeys: String] = [:]) {
        switch string {
        case SpainDeepLink.ecommerce.deepLinkKey: self = .ecommerce
        case SpainDeepLink.bizum.deepLinkKey: self = .bizum
        default: return nil
        }
    }
    
    public var trackerId: String? {
        switch self {
        case .ecommerce:
            return nil
        case .bizum:
            return "bizum"
        }
    }
    
    var deepLinkKey: String {
        switch self {
        case .ecommerce: return "ecommerce"
        case .bizum: return "bizum"
        }
    }
    
    var accessType: DeepLinkAccessType {
        .privateDeepLink
    }
}
