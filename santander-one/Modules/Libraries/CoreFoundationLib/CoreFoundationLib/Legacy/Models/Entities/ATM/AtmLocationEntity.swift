//
//  AtmLocationEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 28/10/2020.
//

import SANLegacyLibrary

public enum AtmCountry: String {
    case es = "ES"
}

public enum AtmLocationType: String {
    case point = "Point"
}

public final class AtmLocationEntity: DTOInstantiable {
    
    public var dto: LocationDTO

    public init(_ dto: LocationDTO) {
        self.dto = dto
    }
    
    public var type: AtmLocationType {
        switch self.dto.type {
        case .point:
            return .point
        }
    }
    
    public var coordinates: [Double] {
        return self.dto.coordinates
    }
    
    public var address: String {
        return self.dto.address
    }
    
    public var zipCode: String {
        return self.dto.zipcode
    }
    
    public var city: String {
        return self.dto.city
    }
    
    public var country: AtmCountry {
        switch self.dto.country {
        case .es:
            return .es
        }
    }
    
    public var locationDetails: String? {
        return self.dto.locationDetails
    }
    
    public var parking: String? {
        return self.dto.parking
    }
    
    public var geoCoords: GeoCoordsDTO {
        return self.dto.geoCoords
    }
    
    public var latitude: Double {
        return self.geoCoords.latitude
    }
    
    public var longitude: Double {
        return self.geoCoords.longitude
    }
}
