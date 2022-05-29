//
//  OfferEntityViewModel.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 05/06/2020.
//

import CoreFoundationLib

public struct OfferEntityViewModel {
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
