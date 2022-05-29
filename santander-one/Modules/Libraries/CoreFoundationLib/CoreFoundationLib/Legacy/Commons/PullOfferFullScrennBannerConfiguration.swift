//
//  PullOffersFullScrennBannerConfiguration.swift
//  RetailClean
//
//  Created by Cristobal Ramos Laina on 23/04/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreDomain

public struct PullOfferFullScreenBannerConfiguration {
    public let banner: BannerEntity
    public let time: Int
    public let action: OfferActionRepresentable?
    public let offerId: String
    public let transparentClosure: Bool
    
    public init(banner: BannerEntity, time: Int, action: OfferActionRepresentable?, offerId: String, transparentClosure: Bool) {
        self.banner = banner
        self.time = time
        self.action = action
        self.offerId = offerId
        self.transparentClosure = transparentClosure
    }
}
