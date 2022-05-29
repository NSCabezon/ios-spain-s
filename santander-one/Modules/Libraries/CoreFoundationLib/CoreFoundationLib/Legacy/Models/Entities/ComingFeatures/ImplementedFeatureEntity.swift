//
//  ImplementedFeatureEntity.swift
//  Models
//
//  Created by José Carlos Estela Anguita on 25/02/2020.
//

import Foundation

public class ImplementedFeatureEntity: DTOInstantiable {
    
    public var dto: ImplementedFeatureDTO
    
    required public init(_ dto: ImplementedFeatureDTO) {
        self.dto = dto
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
