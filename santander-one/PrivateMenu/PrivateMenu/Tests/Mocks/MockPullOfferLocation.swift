//
//  MockPullOfferLocation.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain

struct MockPullOfferLocation: PullOfferLocationRepresentable {
    var stringTag: String
    var hasBanner: Bool
    var pageForMetrics: String?
}

extension MockPullOfferLocation: OfferRepresentable {
    var pullOfferLocation: PullOfferLocationRepresentable? {
        nil
    }
    
    var bannerRepresentable: BannerRepresentable? {
        nil
    }
    
    var action: OfferActionRepresentable? {
        nil
    }
    
    var id: String? {
        nil
    }
    
    var identifier: String {
        ""
    }
    
    var transparentClosure: Bool {
        false
    }
    
    var productDescription: String {
        ""
    }
    
    var rulesIds: [String] {
        [""]
    }
    
    var startDateUTC: Date? {
        nil
    }
    
    var endDateUTC: Date? {
        nil
    }
}
