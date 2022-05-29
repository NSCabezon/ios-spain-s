//
//  FullScreenBannerDTO.swift
//  RetailClean
//
//  Created by Cristobal Ramos Laina on 23/04/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreDomain

public struct FullScreenBannerAction: OfferActionRepresentable {
    
    public let type = "fullscreen-banner"
    public let action: OfferActionRepresentable?
    public let time: Int
    public let banner: BannerDTO
    public let transparentClosure: Bool
    public func getDeserialized() -> String {
        
        var output = ""
        output += "<close_time>\(time)</close_time>"
        output += "<transparent_closure>\(transparentClosure)</transparent_closure>"
        output += "<banner app=\"\(banner.app)\" height=\"\(banner.height)\" width=\"\(banner.width)\">"
        output += "<![CDATA[\(banner.url)]]>"
        output += "</banner>"
        
        if let action = action {
            output += "<action type=\"\(action.type)\">\(action.getDeserialized())</action>"
        }
        
        return output
    }
}
