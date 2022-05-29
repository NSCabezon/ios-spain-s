//
//  PullOfferTipEntity.swift
//  Models
//
//  Created by Juan Carlos López Robles on 1/31/20.
//

import Foundation
import CoreDomain

public final class PullOfferTipEntity: DTOInstantiable {
    public let dto: PullOffersConfigTipDTO
    public var offer: OfferEntity?
    
    @available(*, deprecated, message: "Use init(_ dto: PullOffersConfigTipDTO, offer: OfferDTO) instead.")
    public init(_ dto: PullOffersConfigTipDTO) {
        self.dto = dto
    }
    
    public init(_ dto: PullOffersConfigTipDTO, offer: OfferDTO) {
        self.dto = dto
        self.offer = OfferEntity(offer)
    }
    
    public var title: String? {
        return dto.title
    }
    
    public var description: String? {
        return dto.desc
    }
    
    public  var icon: String? {
        return dto.icon
    }
    
    public var offerId: String? {
        return dto.offerId
    }
    
    public var keyWords: [String]? {
        return dto.keyWords
    }
    
    public var tag: String? {
        return dto.tag
    }
}

extension PullOfferTipEntity: Equatable {
    public static func == (lhs: PullOfferTipEntity, rhs: PullOfferTipEntity) -> Bool {
        return lhs.offerId == rhs.offerId && lhs.title == rhs.title && lhs.offer?.id == rhs.offer?.id
    }
}

extension PullOfferTipEntity: PullOfferTipRepresentable {
    public var offerRepresentable: OfferRepresentable? {
        return self.offer
    }
}
