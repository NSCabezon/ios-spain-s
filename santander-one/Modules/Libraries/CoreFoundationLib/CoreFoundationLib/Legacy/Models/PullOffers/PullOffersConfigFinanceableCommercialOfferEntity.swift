//
//  PullOffersConfigFinanceableCommercialOfferEntity.swift
//  Models
//
//  Created by Ignacio González Miró on 22/12/21.
//

import Foundation
import CoreDomain

public final class PullOffersFinanceableCommercialOfferEntity: DTOInstantiable {
    public let dto: PullOffersFinanceableCommercialOfferDTO

    public init(_ dto: PullOffersFinanceableCommercialOfferDTO) {
        self.dto = dto
    }
    
    public var header: PullOffersFinanceableCommercialOfferHeaderEntity {
        return PullOffersFinanceableCommercialOfferHeaderEntity(dto.header)
    }
    
    public var offers: [PullOffersFinanceableCommercialOfferPillEntity]? {
        guard let offers = dto.offers else { return [] }
        return offers.map { PullOffersFinanceableCommercialOfferPillEntity($0) }
    }
}

public final class PullOffersFinanceableCommercialOfferHeaderEntity: DTOInstantiable {
    public let dto: PullOffersFinanceableCommercialOfferHeaderDTO
    
    public init(_ dto: PullOffersFinanceableCommercialOfferHeaderDTO) {
        self.dto = dto
    }
    
    public var title: String? {
        return dto.title
    }
    
    public var subtitle: String? {
        return dto.subtitle
    }
}

public final class PullOffersFinanceableCommercialOfferPillEntity: DTOInstantiable {
    public let dto: PullOffersFinanceableCommercialOfferPillDTO
    
    public init(_ dto: PullOffersFinanceableCommercialOfferPillDTO) {
        self.dto = dto
    }
    
    public var title: String? {
        return dto.title
    }
    
    public var desc: String? {
        return dto.desc
    }
    
    public var icon: String? {
        return dto.icon
    }
    
    public var locationId: String? {
        return dto.locationId
    }
}
