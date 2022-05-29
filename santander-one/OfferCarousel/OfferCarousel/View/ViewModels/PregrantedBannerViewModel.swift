//
//  PregrantedBannerViewModel.swift
//  Account
//
//  Created by Rubén Márquez Fernández on 23/7/21.
//

import Foundation
import CoreFoundationLib

public struct PregrantedBannerViewModel {
    public var pregrantedBannerColorEnum: PregrantedBannerColor
    public let amount: Float
    public let expirableOfferEntity: ExpirableOfferEntity?
    public let pregrantedBannerText: String
    
    public init(amount: Float,
         expirableOfferEntity: ExpirableOfferEntity? = nil,
         pregrantedBannerColor: PregrantedBannerColor,
         pregrantedBannerText: String) {
        self.amount = amount
        self.expirableOfferEntity = expirableOfferEntity
        self.pregrantedBannerText = pregrantedBannerText
        self.pregrantedBannerColorEnum = pregrantedBannerColor
    }
}
