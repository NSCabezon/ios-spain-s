//
//  GeoCoordsEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 29/10/2020.
//

import SANLegacyLibrary

public struct GeoCoordsEntity: DTOInstantiable {
    
    public var dto: GeoCoordsDTO

    public init(_ dto: GeoCoordsDTO) {
        self.dto = dto
    }
    
    public var latitude: Double {
        return self.dto.latitude
    }
    
    public var longitude: Double {
        return self.dto.longitude
    }
}
