//
//  BizumOrganizationEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 03/02/2021.
//

import Foundation
import SANLegacyLibrary

public final class BizumOrganizationEntity: DTOInstantiable {
    public let dto: BizumOrganizationDTO
    
    public init(_ dto: BizumOrganizationDTO) {
        self.dto = dto
    }
    
    public var identifier: String {
        return self.dto.identifier
    }
    
    public var userType: String {
        return self.dto.userType
    }
    
    public var name: String {
        return self.dto.name
    }
    
    public var alias: String {
        return self.dto.alias
    }
    
    public var documentId: String {
        return self.dto.documentId
    }
    
    public var documentIdType: String {
        return self.dto.documentIdType
    }
    
    public var mail: String {
        return self.dto.mail
    }
    
    public var startDate: Date? {
        return self.dto.startDate
    }
    
    public var endDate: Date? {
        return self.dto.endDate
    }
}
