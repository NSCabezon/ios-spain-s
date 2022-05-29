//
//  AtmEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 27/10/2020.
//

import SANLegacyLibrary

public enum AtmPoiStatus: String {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
    case unknown
}

public final class AtmEntity {
    public var dto: BranchLocatorATMDTO
    public var enrichedDto: BranchLocatorATMEnrichedDTO?
    
    public init(dto: BranchLocatorATMDTO, enrichedDto: BranchLocatorATMEnrichedDTO?) {
        self.dto = dto
        self.enrichedDto = enrichedDto
    }

    public var code: String {
        return self.dto.code
    }
    
    public var entityCode: String {
        return self.dto.entityCode
    }

    public var name: String? {
        return self.dto.name
    }

    public var poiStatus: AtmPoiStatus {
        switch self.dto.poiStatus {
        case .active:
            return .active
        case .inactive:
            return .inactive
        default:
            return .unknown
        }
    }

    public var location: AtmLocationEntity {
        return AtmLocationEntity(self.dto.location)
    }
    
    public var latitude: Double {
        return self.location.latitude
    }
    
    public var longitude: Double {
        return self.location.longitude
    }
    
    public var address: String {
        return self.location.address
    }

    public var distanceInKM: Double {
        return self.dto.distanceInKM
    }

    public var distanceInMiles: Double {
        return self.dto.distanceInMiles
    }
    
    public var hasDispensation: Bool? {
        return self.enrichedDto?.dispensation
    }
    
    public var has10Bills: Bool? {
        return self.enrichedDto?.caj10
    }
    
    public var has20Bills: Bool? {
        return self.enrichedDto?.caj20
    }
    
    public var has50Bills: Bool? {
        return self.enrichedDto?.caj50
    }
    
    public var hasContactLess: Bool? {
        return self.enrichedDto?.contactless
    }
    
    public var hasBarsCode: Bool? {
        return self.enrichedDto?.barsCode
    }
    
    public var hasDeposit: Bool? {
        return self.enrichedDto?.deposit
    }
    
    public var merchantCsb: Int? {
        return self.enrichedDto?.merchantCsb
    }
    
    public var branchCsb: Int? {
        return self.enrichedDto?.branchCsb
    }
    
    public var atmOrder: Int? {
        return self.enrichedDto?.atmOrder
    }
    
    public var stateAtmName: String? {
        return self.enrichedDto?.stateAtmName
    }
    
    public var containEnrichedInformation: Bool {
        return self.enrichedDto != nil
    }
}
