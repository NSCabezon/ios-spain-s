//
//  SmallBottomBannerAction.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 4/27/20.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreDomain

public struct SmallBottomBannerAction: OfferActionRepresentable {
    public let closeTime: Int
    public let banner: BannerDTO
    public let action: OfferActionRepresentable?
    public var type: String = "small-bottom-banner"

    public func getDeserialized() -> String {
        var deserializedObject = "<close_time>\(closeTime)</close_time>"
          deserializedObject +=
            """
            <banner app="\(banner.app)" height="\(banner.height)" width="\(banner.width)">
                <![CDATA[\(banner.url)]]>
            </banner>
            """       
        if let action = action {
            deserializedObject += "<action type=\"\(action.type)\">\(action.getDeserialized())</action>"
        }
        return deserializedObject
    }
}
