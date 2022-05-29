//
//  OfferBannerViewModel.swift
//  Models
//
//  Created by Laura González on 04/09/2020.
//

public struct OfferBannerViewModel {
    private var entity: OfferEntity
    
    public init(entity: OfferEntity) {
        self.entity = entity
    }
    
    public var offer: OfferEntity {
        entity
    }
    
    public var url: String? {
        entity.banner?.url
    }
}
