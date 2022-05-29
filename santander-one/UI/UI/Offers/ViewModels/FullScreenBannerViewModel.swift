//
//  FullScreenBannerViewModel.swift
//  UI
//
//  Created by Cristobal Ramos Laina on 23/04/2020.
//

import Foundation
import CoreDomain
import CoreFoundationLib

class FullScreenBannerViewModel {
    
    var action: OfferActionRepresentable?
    var time: Int
    var banner: BannerEntity
    let transparentClosure: Bool
    
    init(banner: BannerEntity, action: OfferActionRepresentable?, time: Int, transparentClosure: Bool) {
        self.action = action
        self.time = time
        self.banner = banner
        self.transparentClosure = transparentClosure
    }
}
