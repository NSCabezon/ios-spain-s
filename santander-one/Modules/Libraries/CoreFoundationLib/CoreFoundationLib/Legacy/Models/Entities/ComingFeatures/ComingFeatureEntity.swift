//
//  ComingFeatureEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 19/02/2020.
//

import Foundation

public class ComingFeatureEntity {
    
    public var dto: ComingFeatureDTO
    public var isVoted: Bool
    
    public init(dto: ComingFeatureDTO, isVoted: Bool) {
        self.dto = dto
        self.isVoted = isVoted
    }
    
    public var identifier: String {
        return self.dto.identifier
    }
    
    public var title: String {
        return self.dto.title
    }
    
    public var description: String {
        return self.dto.description
    }
    
    public var logo: String {
        return self.dto.logo
    }
    
    public var owner: String {
        return self.dto.owner
    }
    
    public var date: Date {
        return self.dto.date
    }
    
    public var offerPayLoad: OfferPayLoad? {
        return self.dto.offerPayload.flatMap(OfferPayLoad.init)
    }
}
