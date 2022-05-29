//
//  PersonalInformationEntity.swift
//  Models
//
//  Created by Juan Carlos López Robles on 1/28/20.
//

import Foundation
import SANLegacyLibrary

public class PersonalInformationEntity: DTOInstantiable {
    public let dto: PersonBasicDataDTO
    
    required public init(_ dto: PersonBasicDataDTO) {
        self.dto = dto
    }
    
    public var mainAddress: String? {
        return dto.mainAddress
    }
    
    public var addressNodes: [String]? {
        return dto.addressNodes
    }
    
    public var documentType: DocumentType? { // change this it must be exits in other places
        return dto.documentType
    }
    
    public var documentNumber: String? {
        return dto.documentNumber
    }
    
    public var birthDate: Date? {
        return dto.birthDate
    }
    
    public var birthString: String? {
        return dto.birthString
    }
    
    public var phoneNumber: String? {
        return dto.phoneNumber
    }
    
    public var contactHourFrom: Date? {
        return dto.contactHourFrom
    }
    
    public var contactHourTo: Date? {
        return dto.contactHourTo
    }
    
    public var email: String? {
        return dto.email
    }
    
    public var smsPhoneNumber: String? {
        dto.smsPhoneNumber
    }
}
